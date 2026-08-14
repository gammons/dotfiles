# CachyOS Repos in automated_install.py — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `automated_install.py` install Arch with the CachyOS repos and `linux-cachyos` kernel (Approach A from spec).

**Architecture:** Run CachyOS's official `cachyos-repo.sh --install` on the live ISO before archinstall runs, so pacstrap inherits the repos. After base install, ensure the target `/etc/pacman.conf` has the repo sections (copy from ISO if archinstall didn't propagate them), and prepend `cachyos-keyring`/`cachyos-mirrorlist` to the package install.

**Tech Stack:** Python 3, archinstall library (live ISO only), pytest (host, with archinstall stubbed).

**Spec:** `docs/superpowers/specs/2026-08-13-cachyos-repos-design.md`

---

### Task 1: Failing tests (TDD scaffolding)

**Files:**
- Create: `/home/grant/.dotfiles/test_automated_install.py`

- [ ] **Step 1: Write the failing tests**

The module imports `archinstall` at top level, which does not exist on the host. Stub all archinstall modules with `MagicMock` before importing.

```python
import sys
from unittest.mock import MagicMock

ARCHINSTALL_MODULES = [
    "archinstall",
    "archinstall.lib",
    "archinstall.lib.disk",
    "archinstall.lib.disk.device_handler",
    "archinstall.lib.disk.filesystem",
    "archinstall.lib.installer",
    "archinstall.lib.models",
    "archinstall.lib.models.bootloader",
    "archinstall.lib.models.device",
    "archinstall.lib.models.locale",
    "archinstall.lib.models.users",
    "archinstall.lib.output",
]
for _name in ARCHINSTALL_MODULES:
    sys.modules[_name] = MagicMock()

import automated_install as ai

SAMPLE_PACMAN_CONF = """\
[options]
HoldPkg = pacman glibc

[core]
Include = /etc/pacman.d/mirrorlist

[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist
"""


def test_kernels_for_cachyos():
    assert ai.kernels_for(True) == ["linux-cachyos"]


def test_kernels_for_vanilla():
    assert ai.kernels_for(False) == ["linux"]


def test_extract_cachyos_repo_sections():
    sections = ai.extract_cachyos_repo_sections(SAMPLE_PACMAN_CONF)
    assert "[cachyos-v3]" in sections
    assert "cachyos-v3-mirrorlist" in sections
    assert "[cachyos-core-v3]" in sections
    assert "[cachyos]" in sections
    assert "cachyos-mirrorlist" in sections
    assert "[core]" not in sections
    assert "[extra]" not in sections
    assert "[options]" not in sections


def test_extract_cachyos_repo_sections_none():
    assert ai.extract_cachyos_repo_sections("[core]\nInclude = x\n") == ""


def test_ensure_appends_when_missing(tmp_path):
    (tmp_path / "etc").mkdir()
    target = tmp_path / "etc" / "pacman.conf"
    target.write_text("[core]\nInclude = /etc/pacman.d/mirrorlist\n")
    iso = tmp_path / "iso-pacman.conf"
    iso.write_text(SAMPLE_PACMAN_CONF)
    ai.ensure_cachyos_repos_in_target(tmp_path, iso_conf_path=iso)
    text = target.read_text()
    assert "[core]" in text
    assert "[cachyos-v3]" in text
    assert "[cachyos]" in text


def test_ensure_noop_when_present(tmp_path):
    (tmp_path / "etc").mkdir()
    target = tmp_path / "etc" / "pacman.conf"
    original = "[core]\n\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n"
    target.write_text(original)
    iso = tmp_path / "iso-pacman.conf"
    iso.write_text(SAMPLE_PACMAN_CONF)
    ai.ensure_cachyos_repos_in_target(tmp_path, iso_conf_path=iso)
    assert target.read_text() == original
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /home/grant/.dotfiles && python3 -m pytest test_automated_install.py -v`
Expected: FAIL — `AttributeError` for `kernels_for` (and the other new functions).

### Task 2: Config flag + pure helpers

**Files:**
- Modify: `/home/grant/.dotfiles/automated_install.py` (config section ~line 76, and new functions after `load_credentials`)

- [ ] **Step 1: Add the config flag and derive KERNELS**

Replace line 76 (`KERNELS = ["linux"]`) with:

```python
USE_CACHYOS = True
KERNELS = ["linux-cachyos"] if USE_CACHYOS else ["linux"]
```

Also add near the top of the config section:

```python
CACHYOS_REPO_URL = "https://mirror.cachyos.org/cachyos-repo.tar.xz"
```

- [ ] **Step 2: Add helper functions**

Add after `load_credentials` (around line 207):

```python
def kernels_for(use_cachyos: bool) -> list[str]:
    return ["linux-cachyos"] if use_cachyos else ["linux"]


def extract_cachyos_repo_sections(pacman_conf: str) -> str:
    """Extract [cachyos...] repo sections (with their body lines) from pacman.conf text."""
    sections: list[str] = []
    current: list[str] = []
    for line in pacman_conf.splitlines():
        if line.startswith("["):
            if current:
                sections.extend(current)
            current = [line] if line.startswith("[cachyos") else []
        elif current:
            current.append(line)
    if current:
        sections.extend(current)
    return "\n".join(sections)


def ensure_cachyos_repos_in_target(
    mountpoint: Path,
    iso_conf_path: Path = Path("/etc/pacman.conf"),
) -> None:
    """Ensure the target system's pacman.conf has the CachyOS repo sections.

    archinstall's pacstrap should propagate the ISO's pacman.conf, but if the
    [cachyos...] sections are missing, copy them from the ISO's pacman.conf.
    """
    target_conf = mountpoint / "etc" / "pacman.conf"
    text = target_conf.read_text()
    if "[cachyos" in text:
        info("Target pacman.conf already has CachyOS repos")
        return
    warn("Target pacman.conf missing CachyOS repos; copying from ISO")
    sections = extract_cachyos_repo_sections(iso_conf_path.read_text())
    if not sections:
        raise RuntimeError("No CachyOS repo sections found in ISO pacman.conf")
    with target_conf.open("a") as f:
        f.write("\n" + sections + "\n")
```

(`KERNELS` uses the inline conditional because the config section sits above the function definitions; `kernels_for` exists so the logic is unit-testable.)

- [ ] **Step 3: Run tests to verify they pass**

Run: `cd /home/grant/.dotfiles && python3 -m pytest test_automated_install.py -v`
Expected: all 6 tests PASS.

- [ ] **Step 4: Commit**

```bash
cd /home/grant/.dotfiles
git add automated_install.py test_automated_install.py
git commit -m "Add CachyOS config flag and pacman.conf helpers"
```

### Task 3: Repo setup function + wiring into the install flow

**Files:**
- Modify: `/home/grant/.dotfiles/automated_install.py`

- [ ] **Step 1: Add `setup_cachyos_repos()`**

Add after `ensure_cachyos_repos_in_target`:

```python
def setup_cachyos_repos() -> None:
    """Configure CachyOS repos on the live ISO (auto-detects x86-64 v3/v4 tier)."""
    import subprocess
    import tempfile
    import urllib.request

    with tempfile.TemporaryDirectory() as tmpdir:
        tarball = Path(tmpdir) / "cachyos-repo.tar.xz"
        info(f"Downloading CachyOS repo setup from {CACHYOS_REPO_URL}...")
        urllib.request.urlretrieve(CACHYOS_REPO_URL, tarball)
        subprocess.run(["tar", "-xf", str(tarball), "-C", tmpdir], check=True)
        script = Path(tmpdir) / "cachyos-repo" / "cachyos-repo.sh"
        info("Running cachyos-repo.sh --install (auto-detects CPU tier)...")
        subprocess.run(["bash", str(script), "--install"], check=True)

    info("Verifying CachyOS repos...")
    subprocess.run(["pacman", "-Sy", "--noconfirm"], check=True)
    result = subprocess.run(["pacman", "-Si", "linux-cachyos"], capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(
            "CachyOS repos configured but linux-cachyos not found. "
            "Fix the network/mirror issue or set USE_CACHYOS = False."
        )
```

- [ ] **Step 2: Call it in `perform_installation()`**

At the top of `perform_installation()`, right after `encryption_password = creds_dict.get("encryption_password")` (~line 391), add:

```python
    if USE_CACHYOS and not dry_run:
        setup_cachyos_repos()
```

- [ ] **Step 3: Ensure target pacman.conf after base install**

In `perform_installation()`, immediately after the `installation.minimal_installation(...)` block (~line 510), add:

```python
        if USE_CACHYOS:
            ensure_cachyos_repos_in_target(MOUNTPOINT)
```

- [ ] **Step 4: Prepend keyring/mirrorlist to the package install**

Replace `installation.add_additional_packages(PACKAGES)` (~line 534) with:

```python
        packages = (["cachyos-keyring", "cachyos-mirrorlist"] if USE_CACHYOS else []) + PACKAGES
        installation.add_additional_packages(packages)
```

- [ ] **Step 5: Update dry-run output**

In the `dry_run` block, after the `info(f"Kernels: {KERNELS}")` line (~line 452), add:

```python
        if USE_CACHYOS:
            info("CachyOS: repos configured on live ISO via cachyos-repo.sh --install (auto-detected tier)")
            info("  - extra packages: cachyos-keyring, cachyos-mirrorlist")
```

- [ ] **Step 6: Verify syntax and tests**

Run: `cd /home/grant/.dotfiles && python3 -m py_compile automated_install.py && python3 -m pytest test_automated_install.py -v`
Expected: compiles cleanly, all 6 tests PASS.

- [ ] **Step 7: Commit**

```bash
cd /home/grant/.dotfiles
git add automated_install.py
git commit -m "Add CachyOS repo setup to automated install"
```

### Task 4: VM end-to-end test

**Files:** none (verification only)

The QEMU VM from `~/vm/archtest` is running the Arch live ISO. The guest can reach the host at `10.0.2.2` under QEMU user-mode networking.

- [ ] **Step 1: Serve the dotfiles dir from the host**

Run on the host:
```bash
cd /home/grant/.dotfiles && python3 -m http.server 8000
```
(Leave running; kill after the test.)

- [ ] **Step 2: Dry-run in the VM**

In the VM console:
```bash
curl -O http://10.0.2.2:8000/automated_install.py
curl -O http://10.0.2.2:8000/user_credentials.json.template
cp user_credentials.json.template user_credentials.json
# edit user_credentials.json with test passwords
python automated_install.py --device /dev/vda --dry-run
```
Expected: dry-run shows `Kernels: ['linux-cachyos']` and the CachyOS lines.

- [ ] **Step 3: Full install in the VM**

```bash
python automated_install.py --device /dev/vda
```
Expected: `cachyos-repo.sh` runs at the start and detects the tier; install completes; reboot (remove ISO or change boot order, then boot the qcow2).

- [ ] **Step 4: Post-install verification in the VM**

```bash
uname -r                          # contains "cachyos"
grep -A2 '\[cachyos' /etc/pacman.conf   # repo sections present
pacman -Q cachyos-keyring cachyos-mirrorlist linux-cachyos
```
Expected: all present/installed.

- [ ] **Step 5: Also verify vanilla fallback**

Dry-run only: set `USE_CACHYOS = False`, re-run dry-run in VM.
Expected: `Kernels: ['linux']`, no CachyOS lines. Then set it back to `True`.
