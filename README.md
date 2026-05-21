# nix-server

NixOS server configuration using the
[dendritic pattern](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
with flake-parts.

## Test VM

Build and run a local VM with all services:

```sh
nix run .#test
```

This starts a headless QEMU VM with:

- All services running with dummy secrets
- Caddy serving plain HTTP (no TLS warnings)
- Port forwarding: `localhost:8080` (HTTP), `localhost:2222` (SSH)

Access services at `http://<subdomain>.localhost:8080`, e.g.:

- http://localhost:8080 — Homepage
- http://cloud.localhost:8080 — Nextcloud
- http://jelly.localhost:8080 — Jellyfin

SSH into the VM:

```sh
ssh -p 2222 localhost
```

The VM auto-logs in as root on the console. Type `off` to shut it down.

Delete `*.qcow2` to reset the VM disk between runs.
