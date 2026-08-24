import sys
from unittest.mock import MagicMock

ARCHINSTALL_MODULES = [
    "archinstall",
    "archinstall.lib",
    "archinstall.lib.disk",
    "archinstall.lib.disk.device_handler",
    "archinstall.lib.disk.filesystem",
    "archinstall.lib.installer",
    "archinstall.lib.locale",
    "archinstall.lib.log",
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


# =============================================================================
# Fingerprint reader (fprintd) provisioning
# =============================================================================


def _greeter_stack(commands: list[str]) -> str:
    """The heredoc that writes /etc/pam.d/greetd-greeter."""
    return next(c for c in commands if "/etc/pam.d/greetd-greeter" in c)


def _user_stack(commands: list[str]) -> str:
    """The heredoc that writes /etc/pam.d/greetd (not greetd-greeter)."""
    return next(
        c
        for c in commands
        if "/etc/pam.d/greetd <<" in c or "/etc/pam.d/greetd << " in c
    )


def _active_pam_lines(stack: str) -> list[str]:
    """PAM directives only, ignoring comments and the heredoc wrapper."""
    lines = []
    for line in stack.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("cat >"):
            continue
        if stripped.endswith("_EOF"):
            continue
        lines.append(stripped)
    return lines


def test_greeter_pam_stack_excludes_fprintd():
    """greetd starts the greeter session unauthenticated; pam_fprintd's
    pam_setcred returns PERM_DENIED there and crashes the daemon."""
    commands = ai.get_fingerprint_commands(["grant"])
    active = _active_pam_lines(_greeter_stack(commands))
    assert active, "expected some PAM directives"
    assert not any("pam_fprintd" in line for line in active)


def test_greeter_pam_stack_does_not_include_shared_auth_chain():
    """Including system-local-login would pull in pam_fprintd transitively."""
    commands = ai.get_fingerprint_commands(["grant"])
    auth_lines = [
        line for line in _active_pam_lines(_greeter_stack(commands))
        if line.startswith("auth") or line.startswith("-auth")
    ]
    assert auth_lines
    assert not any("system-local-login" in line for line in auth_lines)


def test_greeter_pam_stack_authenticates_with_pam_unix():
    commands = ai.get_fingerprint_commands(["grant"])
    assert "pam_unix.so" in _greeter_stack(commands)


def test_user_pam_stack_includes_shared_chain():
    """The real login session reaches pam_fprintd through system-auth."""
    commands = ai.get_fingerprint_commands(["grant"])
    assert "system-local-login" in _user_stack(commands)


def test_system_auth_edit_is_idempotent():
    """Re-running provisioning must not stack duplicate pam_fprintd lines."""
    commands = ai.get_fingerprint_commands(["grant"])
    edit = next(c for c in commands if "system-auth" in c and "sed" in c)
    assert "grep -q" in edit


def test_system_auth_edit_inserts_fprintd_before_pam_unix():
    commands = ai.get_fingerprint_commands(["grant"])
    edit = next(c for c in commands if "system-auth" in c and "sed" in c)
    assert "pam_fprintd.so" in edit
    # Anchored on the auth pam_unix line, inserted above it (sed `i`).
    assert "pam_unix" in edit
    assert "/i " in edit


def test_polkit_rule_grants_each_user():
    commands = ai.get_fingerprint_commands(["grant", "grant-work"])
    rule = next(c for c in commands if "50-fprintd.rules" in c)
    assert "grant" in rule
    assert "grant-work" in rule


def test_polkit_rule_covers_enroll_and_verify():
    commands = ai.get_fingerprint_commands(["grant"])
    rule = next(c for c in commands if "50-fprintd.rules" in c)
    assert "net.reactivated.fprint.device.enroll" in rule
    assert "net.reactivated.fprint.device.verify" in rule


def test_fprintd_in_packages():
    assert "fprintd" in ai.PACKAGES


def test_post_install_includes_fingerprint_setup():
    commands = ai.get_post_install_commands(["grant"])
    assert any("50-fprintd.rules" in c for c in commands)


def test_greetd_config_pins_greeter_pam_service():
    """Relying on greetd's built-in default leaves the greeter's PAM service
    implicit; pin it so the fprintd-free stack is always the one used."""
    commands = ai.get_post_install_commands(["grant"])
    config = next(c for c in commands if "/etc/greetd/config.toml" in c)
    assert 'service = "greetd-greeter"' in config
