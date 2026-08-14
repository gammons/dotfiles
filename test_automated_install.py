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


def test_ensure_inserts_before_core_when_missing(tmp_path):
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
    assert text.index("[cachyos") < text.index("[core]")


def test_ensure_raises_when_iso_has_no_cachyos_sections(tmp_path):
    import pytest

    (tmp_path / "etc").mkdir()
    target = tmp_path / "etc" / "pacman.conf"
    target.write_text("[core]\nInclude = /etc/pacman.d/mirrorlist\n")
    iso = tmp_path / "iso-pacman.conf"
    iso.write_text("[core]\nInclude = /etc/pacman.d/mirrorlist\n")
    with pytest.raises(RuntimeError):
        ai.ensure_cachyos_repos_in_target(tmp_path, iso_conf_path=iso)


def test_ensure_noop_when_present(tmp_path):
    (tmp_path / "etc").mkdir()
    target = tmp_path / "etc" / "pacman.conf"
    original = "[core]\n\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n"
    target.write_text(original)
    iso = tmp_path / "iso-pacman.conf"
    iso.write_text(SAMPLE_PACMAN_CONF)
    ai.ensure_cachyos_repos_in_target(tmp_path, iso_conf_path=iso)
    assert target.read_text() == original
