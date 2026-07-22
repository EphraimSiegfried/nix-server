# ares crash investigation (2026-07-20, updated 2026-07-22)

## Symptom

`ares` intermittently becomes fully unresponsive: local SSH is dead, all services
are down, but the box hasn't rebooted. Connecting a monitor+keyboard directly
shows the tty spinning on repeated `systemd-journald` errors.

## Evidence (from tty photos)

- `systemd-journald[719]: Failed to write entry to /var/log/journal/.../system.journal ... Input/output error`
  repeated hundreds of times, plus `Failed to rotate ... Input/output error`.
- After a manual reboot, `journalctl --verify` found real on-disk corruption:
  `Invalid hash`, `Invalid object contents: Bad message`,
  `File corruption detected at .../system@....journal:37187440 (of 41943040 bytes, 88%)`.

This is a storage-layer symptom (data getting corrupted at or before the point
it's written to the ext4 root filesystem), not an application-level bug.

## Hardware (order 148892204, delivered 3–6.6.2025)

- Motherboard: ASUS TUF GAMING B760M-PLUS II
- CPU: Intel Core i5-14600K (tray)
- RAM: Kingston FURY Beast
- Cooler: Noctua NH-L9x65 (low-profile)
- PSU: Seasonic Focus SGX (500–750W SFX, 80+ Gold) — reputable, adequately sized, ruled out
- Case: Jonsbo N4
- SSD: 4TB NVMe, reputable brand, obtained **secondhand from a friend** (not part of
  the order above), plugged directly into a motherboard M.2 slot, has a heatsink

## Ruled out

- Counterfeit-capacity SSD — brand is reputable.
- Bad USB/PCIe adapter — SSD is direct in a motherboard M.2 slot.
- Underpowered/bad PSU — Seasonic Focus SGX has plenty of headroom for this build.
- Pure thermal shutdown — heatsink present, and crashes don't correlate with load.

## Leading suspect: CPU/motherboard voltage instability (Intel Raptor Lake bug)

The i5-14600K is a K-series 13th/14th-gen ("Raptor Lake") CPU, which is on Intel's
list of chips affected by a microcode bug that requested elevated core voltage
(a Vmin shift), causing silent computational errors under normal use. ASUS only
started shipping safe "Intel Default Settings" as the BIOS factory default from
**May 2024** onward. The board here has **never had its BIOS updated** since
purchase — so it's plausibly still on aggressive/unsafe power defaults.

This matches the observed pattern:

- Crashes happened from day one (unsafe defaults were there from the start).
- Pattern is "random"/workload-independent (voltage excursions are transient,
  not simple thermal throttling).
- The failure shows up as filesystem corruption, not a clean kernel panic — a
  corrupted computation can silently corrupt metadata on the way to disk without
  ever triggering a hard-lockup detector.
- The instability may also cause the box to appear "frozen but not crashed" (see
  watchdog gap below): the kernel and PID1 can stay alive while individual I/O
  operations keep failing.

**Important distinction:** this isn't necessarily a manufacturing defect ("damaged"
CPU) — it's a firmware/microcode issue that can be fixed with a BIOS update.
However, running a chip in this unstable voltage state for a long time (this one
has been running 24/7 since ~June 2025) can cause **permanent degradation**
(a lasting Vmin shift) — which is why Intel ran an RMA program for chips that were
already damaged before the fix was applied. The BIOS update fixes the *ongoing*
instability; whether the chip is *also* already partially degraded can only be
determined by seeing whether crashes persist after the fix.

## Secondary/open question: SSD health

The SSD is secondhand with unknown prior usage, and the repo currently has **no
SMART/disk-health monitoring configured at all** (no `smartd`, no textfile
collector, nothing in `modules/services/monitoring/`). Not a strong suspect given
reputable brand + direct M.2 slot + heatsink, but can't be ruled out without data.

## Existing watchdog doesn't cover this failure mode

`modules/system/watchdog.nix` only arms:

- NMI hard-lockup detection (`nmi_watchdog=1`)
- systemd `RuntimeWatchdogSec=30` / `RebootWatchdogSec=2min` (PID1-hang detection)

Neither fires when the disk is returning `EIO` on every write but the kernel and
PID1 are otherwise alive — which is exactly what happened here. This is why the
box just sat there instead of self-recovering.

## Session findings 2026-07-22 (BIOS photo + SMART + Loki forensics)

### BIOS confirmed pre-fix (photo of BIOS Main screen)

- **BIOS 0602, build 12/15/2023** — the board's *initial release* BIOS. Predates
  every Raptor Lake fix: 0x125 (eTVB), 0x129 (voltage requests), 0x12B (idle
  voltage/Vmin), 0x12F (Vmin), and ASUS's "Intel Default Settings" defaults
  (BIOS 1658, May 2024). ME FW 16.1.30.2307.
- **Core voltage 1.421 V at 53x/5300 MHz** visible in the BIOS hardware monitor —
  the elevated-voltage behavior the microcode bug produces, observed directly.
- RAM at JEDEC 4800 MHz / 1.120 V — **XMP is off**, RAM OC eliminated as a factor.
- ASUS BIOS page confirms **direct flash 0602 → 1836 is supported** (no
  intermediate version required; the CAP bundles the ME firmware update
  16.1.30.2307 → 16.1.40.2765, which is one-way — ME stays updated even if the
  BIOS is rolled back later).

### SSD formally cleared (smartctl 2026-07-22)

Samsung 990 PRO 4TB (S7DSNJ0X900973K), FW 4B2QJXD7:
`Media and Data Integrity Errors: 0`, `Error Information Log Entries: 0`,
`Critical Warning: 0x00`, spare 100%, 3% used, 10,377 POH, 41.9 TB written
(rated 2,400 TBW), 86 unsafe shutdowns (scar tissue from the crashes themselves).

Key inference: `journalctl --verify` found corrupted bytes on disk, but the
drive has never recorded a single media error — so corruption entered the data
**upstream of the drive** (CPU/memory path), or the EIO storm was the NVMe
*link* dropping (also traceless at the media layer). Both point at the platform,
not the SSD.

### Loki forensics for the 2026-07-19 crash (gap 14:13–23:23 CEST)

- Last shipped lines: **14:15:04 CEST**, mid `jellyseerr` Jellyfin-sync burst.
- Two scheduled jobs (Download Sync + Recently Added Scan) started at exactly
  **14:15:00** — death 4 seconds into an idle→load transition, the textbook
  Vmin-instability trigger that 0x12B/0x12F address.
- **Zero** `mce`/`nvme`/`ext4`/`blk_update` warnings in the hours before —
  instant death, no degradation curve.
- Structural note: Loki can never capture the actual trigger line — journald's
  writes are the first casualty, so promtail has nothing to ship. tty photos are
  the only record of the failure itself.

### Decisions

- **Storage-health watchdog (old item 6): dropped.** It treats the symptom, not
  the cause, and auto-reboots would mask the "did the crashes stop?" signal we
  need post-flash.
- **smartctl exporter added** to `modules/services/monitoring/prometheus.nix`
  (port 9003, scraping `/dev/nvme0n1` + `/dev/sda`, 60s interval) — permanent
  disk-health visibility in Grafana.
- **fsck + journal cleanup** folded into the flash downtime: `touch /forcefsck`
  before the reboot; afterwards `journalctl --rotate` and delete journal files
  flagged corrupt by `journalctl --verify`.
- **Success criteria:** historical crash cadence was ~every 1–2 weeks (bursts of
  every-other-day). **6 crash-free weeks (until ~2026-09-02) = cured.** Any
  freeze after the flash (with Intel Default Settings confirmed) = the chip took
  permanent Vmin damage during 13 months at elevated voltage → start Intel RMA
  (14600K has 3-year warranty).

## Action plan (status as of 2026-07-22)

1. ~~Update the motherboard BIOS to 1836~~ ✅ flashed 2026-07-22 via EZ Flash
   (stick needed a clean MBR + single FAT32 partition before EZ Flash saw it).
   ME FW updated alongside. Post-boot check 2026-07-22 18:57: **microcode
   revision 0x133** (well past the 0x12B/0x12F Vmin fixes) — the fix is live.
   Root fsck at boot reported "clean" but note: NixOS stage-1 fsck runs `-a`,
   which skips the deep scan when the clean bit is set (`/forcefsck` isn't
   visible to stage-1 since / isn't mounted yet). Optional full check at a
   future reboot: `tune2fs -c 1 /dev/nvme0n1p2`, reboot, then
   `tune2fs -c -1 /dev/nvme0n1p2`. Still pending: journal cleanup
   (`journalctl --rotate` + delete files flagged by `--verify`) and
   `nixos-rebuild switch` to deploy the smartctl exporter.
2. ~~Re-apply BIOS settings~~ ✅ 2026-07-22: **Intel Default Settings** selected,
   Restore AC Power Loss → Power On, fan curves re-applied, XMP left off.
3. ~~Check Loki around a past crash~~ ✅ done 2026-07-22 — see findings above.
   No trigger line recoverable (journald dies first); timing evidence supports
   the Vmin theory.
4. ~~Add SMART monitoring~~ ✅ smartctl exporter added to `prometheus.nix`;
   deploy with the next rebuild.
5. ~~Run smartctl on the SSD~~ ✅ done 2026-07-22 — clean, SSD cleared.
6. ~~Add a storage-health watchdog~~ ❌ dropped — treats symptom, masks the
   post-flash recovery signal.
7. Watch whether crashes recur after the BIOS fix: **6 crash-free weeks
   (~2026-09-02) = cured**; any freeze → Intel RMA (chip likely has permanent
   Vmin-shift degradation from 13 months at elevated voltage).

## BIOS/firmware upgrade steps (ASUS TUF GAMING B760M-PLUS II)

Latest BIOS at time of writing: **version 1836** (released 2026-05-18) — release
notes explicitly cover Intel microcode updates and redefine factory defaults
around Intel's "Intel Default Settings".

Download page: https://www.asus.com/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b760m-plus-ii/helpdesk_bios?model2Name=TUF-GAMING-B760M-PLUS-II

EZ Flash method (works with just the HDMI+keyboard already used to view crash logs):

1. Download the latest BIOS `.zip` from the page above.
2. Format a USB drive as **FAT32**, extract the `.CAP` file to its root directory.
3. Boot the server, press **Del** (or F2) during POST to enter BIOS setup.
4. Switch to **Advanced Mode** if needed (F7).
5. Go to **Tool → ASUS EZ Flash Utility**.
6. Select the USB drive, then the `.CAP` file, confirm the version, and flash.
7. **Do not power off, unplug, or remove the USB drive during the flash** — an
   interrupted flash can brick the board. It reboots automatically when done.
8. Re-enter BIOS setup and confirm **Performance Preferences → Intel Default
   Settings** is selected.
9. Save & exit.

(Some TUF boards also support **USB BIOS FlashBack**, flashing without powering
on the system at all, via a dedicated port+button — check the manual for whether
this board has it. Not required here since EZ Flash works fine.)
