# CachyOS Repos in automated_install.py — Design

Date: 2026-08-13

## Goal

Extend `automated_install.py` so the installed system uses the CachyOS
package repositories and the `linux-cachyos` kernel instead of vanilla Arch
packages/kernel.

## Decisions

- Scope: repos + kernel (linux-cachyos replaces vanilla `linux`).
- Repo tier (x86-64-v3 vs v4) is auto-detected via CachyOS's official
  `cachyos-repo.sh` script — no hardcoding.
- Integration strategy: **Approach A** — configure the repos in the live ISO
  before archinstall runs, so pacstrap and all subsequent package installs
  pull optimized CachyOS builds in a single pass.

## Design

### Configuration

New constant at the top of the script's config section:

```python
USE_CACHYOS = True
```

`KERNELS` is derived from the flag:

```python
KERNELS = ["linux-cachyos"] if USE_CACHYOS else ["linux"]
```

Setting `USE_CACHYOS = False` fully reverts to the previous vanilla behavior.

### `setup_cachyos_repos()` (new function)

Called at the start of `perform_installation()` on real (non-dry-run) runs,
before any archinstall work. Operates on the live ISO environment:

1. Download `https://mirror.cachyos.org/cachyos-repo.tar.xz` to a temp dir
   and extract it.
2. Run the extracted `cachyos-repo.sh` (auto-detects x86-64-v3/v4, installs
   the CachyOS keyring + mirrorlist, updates the ISO's `/etc/pacman.conf`).
3. Verify: `pacman -Sy`, then `pacman -Si linux-cachyos`. If either fails,
   abort with a clear error telling the user to fix the network/mirror issue
   or set `USE_CACHYOS = False`.

### Target system propagation

archinstall's pacstrap inherits the ISO's pacman config, so the base system
and `linux-cachyos` kernel install from the CachyOS repos automatically.

Immediately after `installation.minimal_installation()`:

1. Check whether `/mnt/etc/pacman.conf` contains a `[cachyos` repo section.
   If missing, copy the CachyOS repo sections from the ISO's
   `/etc/pacman.conf` into the target config.
2. Prepend `cachyos-keyring` and `cachyos-mirrorlist` to the packages
   installed via `add_additional_packages()` so all subsequent package
   installs resolve signatures and mirrors correctly.

### Error handling

Fail fast. Any failure in repo setup or verification aborts the installation
with an actionable message. No silent fallback to vanilla Arch.

### Dry-run output

When `USE_CACHYOS` is enabled, the dry-run output states:
- CachyOS repos will be configured via the official script (auto-detected tier)
- Kernel: `linux-cachyos`
- `cachyos-keyring` and `cachyos-mirrorlist` added to the package set

## Testing

In the QEMU test VM (`~/vm/archtest`):

1. `python automated_install.py --device /dev/vda --dry-run` — verify output.
2. Full install: `python automated_install.py --device /dev/vda`.
3. Post-install verification in the VM:
   - `uname -r` contains `cachyos`
   - `/etc/pacman.conf` contains the CachyOS repo sections
   - `pacman -Qm`/`pacman -Si <pkg>` shows packages from a cachyos repo
4. Also verify a dry-run with `USE_CACHYOS = False` still shows vanilla
   `linux` and no CachyOS steps.

## Out of scope

- CachyOS's own installer/DE defaults, sysctl tweaks, or scheduler config.
- Installing both kernels side-by-side (vanilla was not kept as a fallback).
