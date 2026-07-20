# ares crash investigation (2026-07-20)

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

## Action plan

1. **Update the motherboard BIOS** (see steps below) — highest-leverage fix,
   pulls in current Intel microcode and safe power-limit defaults.
2. After updating, confirm the **"Performance Preferences"** BIOS setting is
   **"Intel Default Settings"**, not an enhanced/OC profile.
3. **Check the Loki instance** (`https://grafana.qew.ch`, `{host="ares"}`) around
   a past crash timestamp for `mce`, `hardware error`, `nvme`, or
   `blk_update_request` lines — logs are shipped there live via promtail before
   local corruption happens, so the real trigger line may still be recoverable.
4. **Add SMART monitoring** (`smartd` or a `smartctl_exporter`/textfile collector
   feeding the existing Prometheus `node_exporter`) — currently zero visibility
   into disk health.
5. **Run `smartctl -a` / `nvme smart-log`** on the SSD to check `media_errors`,
   `percentage_used`, `critical_warning` and close the loop on the secondhand
   drive.
6. **Add a storage-health watchdog** — a systemd timer that writes+fsyncs a test
   file to `/` and force-reboots on failure, since the current watchdog module is
   blind to this failure mode.
7. Watch whether crashes recur after the BIOS fix. If they do, the CPU may
   already be degraded and worth pursuing Intel's RMA program for affected
   13th/14th-gen chips; if not, this was the whole story.

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
