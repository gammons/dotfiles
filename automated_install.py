#!/usr/bin/env python3
"""
Automated Arch Linux installation script using archinstall.

This script performs a fully automated installation with all configuration
embedded directly in the script. Only user_credentials.json is required
for sensitive data (passwords, users, encryption key).

Usage:
    python automated_install.py [--creds CREDS_PATH] [--device DEVICE] [--dry-run]

Run this script from the Arch Linux live ISO environment.

Files:
    - user_credentials.json: Sensitive data (passwords, users) - keep this secure!
"""

import json
import sys
from pathlib import Path

# IMPORTANT: archinstall.lib.args has a global that parses sys.argv on import.
# We need to save our args and temporarily hide them before importing archinstall.
_saved_argv = sys.argv.copy()
sys.argv = [sys.argv[0]]  # Keep only script name during import

from archinstall.lib.disk.device_handler import device_handler
from archinstall.lib.disk.filesystem import FilesystemHandler
from archinstall.lib.installer import Installer, run_custom_user_commands
from archinstall.lib.models.bootloader import Bootloader, BootloaderConfiguration
from archinstall.lib.models.device import (
    DeviceModification,
    DiskEncryption,
    DiskLayoutConfiguration,
    DiskLayoutType,
    EncryptionType,
    FilesystemType,
    ModificationStatus,
    PartitionFlag,
    PartitionModification,
    PartitionType,
    Size,
    SubvolumeModification,
    Unit,
)
from archinstall.lib.models.locale import LocaleConfiguration
from archinstall.lib.models.users import Password, User
try:
    from archinstall.lib.log import error, info, warn
except ImportError:
    from archinstall.lib.output import error, info, warn

# Restore original argv for our own argument parsing
sys.argv = _saved_argv


# =============================================================================
# CONFIGURATION - Edit these values to customize your installation
# =============================================================================

# Credentials file path
CREDS_PATH = Path(__file__).parent / "user_credentials.json"

# Target device - can be overridden with --device flag
DEFAULT_DEVICE = "/dev/sda"

# Mount point for installation
MOUNTPOINT = Path("/mnt")

# Disk layout settings
BOOT_SIZE_GIB = 1       # Boot partition size in GiB

# System settings
HOSTNAME = "archlinux"
TIMEZONE = "America/New_York"
LOCALE_LANG = "en_US.UTF-8"
LOCALE_ENCODING = "UTF-8"
KEYBOARD_LAYOUT = "us"
CACHYOS_REPO_URL = "https://mirror.cachyos.org/cachyos-repo.tar.xz"
USE_CACHYOS = True
KERNELS = ["linux-cachyos"] if USE_CACHYOS else ["linux"]

# Bootloader
BOOTLOADER = Bootloader.Systemd
USE_UKI = True  # Unified Kernel Image

# Packages to install
PACKAGES = [
    # Base development
    "base-devel",
    "git",
    # Shell
    "zsh",
    # Terminal & CLI tools
    "alacritty",
    "atuin",
    "bat",
    "btop",
    "eza",
    "fd",
    "fzf",
    "jq",
    "neovim",
    "starship",
    "stow",
    "the_silver_searcher",
    "tig",
    "tmux",
    "tree-sitter",
    "tree-sitter-lua",
    "wget",
    # Sway & Wayland (sway is replaced by swayfx from AUR in post-install)
    "fuzzel",
    "grim",
    "playerctl",
    "slurp",
    "sway",
    "swappy",
    "swaybg",
    "swayidle",
    "swaync",
    "swayosd",
    "uwsm",
    "waybar",
    "wl-clipboard",
    "wlsunset",
    "xdg-desktop-portal-gtk",
    "xdg-desktop-portal-wlr",
    # Display manager
    "greetd-tuigreet",
    # Audio
    "pavucontrol",
    "pipewire",
    "pipewire-alsa",
    "pipewire-jack",
    "pipewire-pulse",
    "wireplumber",
    # Networking
    # NetworkManager with iwd backend for wifi management
    # (noctalia requires NetworkManager for its wifi panel)
    "inetutils",
    "iwd",
    "networkmanager",
    "openssh",
    "tailscale",
    # Fonts
    "noto-fonts",
    "noto-fonts-cjk",
    "noto-fonts-emoji",
    "noto-fonts-extra",
    "ttf-cascadia-mono-nerd",
    "ttf-roboto-mono-nerd",
    # Docker & K8s
    "docker",
    "docker-buildx",
    "docker-compose",
    "helm",
    "k9s",
    # Cloud & Dev tools
    "aws-cli",
    "bun",
    "github-cli",
    "go",
    "mise",
    "nodejs",
    "pnpm",
    # Desktop apps
    "obsidian",
    # Backup
    "restic",
    # System
    "brightnessctl",
    "impala",
    "keychain",
    "polkit",
    "quickshell",
    "screenfetch",
    # Printing (Brother network printer support via IPP Everywhere)
    "avahi",
    "cups",
    "ghostscript",
    "gsfonts",
    "nss-mdns",
    "system-config-printer",
]

# Services to enable
SERVICES = [
    "avahi-daemon",
    "cups.socket",
    "docker",
    "iwd",
    "NetworkManager",
    "systemd-resolved",
    "tailscaled",
]

# =============================================================================
# END CONFIGURATION
# =============================================================================


def load_credentials(creds_path: Path) -> dict:
    """Load credentials from JSON file."""
    if not creds_path.exists():
        warn(f"Credentials file not found: {creds_path}")
        warn("Using default/empty credentials - you should provide a credentials file!")
        return {}

    with open(creds_path) as f:
        return json.load(f)


def kernels_for(use_cachyos: bool) -> list[str]:
    return ["linux-cachyos"] if use_cachyos else ["linux"]


def extract_cachyos_repo_sections(pacman_conf: str) -> str:
    """Extract [cachyos...] repo sections (with their body lines) from pacman.conf text."""
    sections: list[str] = []
    current: list[str] = []
    for line in pacman_conf.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("["):
            if current:
                sections.extend(current)
            current = [line] if stripped.startswith("[cachyos") else []
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
    lines = target_conf.read_text().splitlines()
    if any(line.lstrip().startswith("[cachyos") for line in lines):
        info("Target pacman.conf already has CachyOS repos")
        return
    warn("Target pacman.conf missing CachyOS repos; copying from ISO")
    sections = extract_cachyos_repo_sections(iso_conf_path.read_text())
    if not sections:
        raise RuntimeError("No CachyOS repo sections found in ISO pacman.conf")
    insert_at = len(lines)
    for i, line in enumerate(lines):
        stripped = line.lstrip()
        if stripped.startswith("[") and not stripped.startswith("[options]"):
            insert_at = i
            break
    new_lines = lines[:insert_at] + sections.splitlines() + [""] + lines[insert_at:]
    target_conf.write_text("\n".join(new_lines) + "\n")


def setup_cachyos_repos() -> None:
    """Configure CachyOS repos on the live ISO (auto-detects x86-64 v3/v4 tier)."""
    import subprocess
    import tempfile

    with tempfile.TemporaryDirectory() as tmpdir:
        tarball = Path(tmpdir) / "cachyos-repo.tar.xz"
        info(f"Downloading CachyOS repo setup from {CACHYOS_REPO_URL}...")
        subprocess.run(
            ["curl", "-fSL", "-o", str(tarball), CACHYOS_REPO_URL], check=True
        )
        subprocess.run(["tar", "-xf", str(tarball), "-C", tmpdir], check=True)
        script = Path(tmpdir) / "cachyos-repo" / "cachyos-repo.sh"
        # The script ends with an unconditional `pacman -Syu`, which upgrades the
        # entire live ISO system into RAM (airootfs) and can run out of space or
        # upgrade archinstall mid-run. Neutralize it; we only need the repo setup.
        # Also add --noconfirm to its `pacman -U` so nothing prompts.
        subprocess.run(
            ["sed", "-i", "-E",
             "-e", r"s/^([[:space:]]*)pacman -Syu[[:space:]]*$/\1true/",
             "-e", r"s/^([[:space:]]*)pacman -U /\1pacman -U --noconfirm /",
             str(script)],
            check=True,
        )
        info("Running cachyos-repo.sh --install (auto-detects CPU tier)...")
        # The script uses relative paths (./install-*.awk, ./pacman.conf),
        # so it must run with its own directory as cwd.
        subprocess.run(
            ["bash", str(script), "--install"], check=True, cwd=script.parent
        )

    info("Verifying CachyOS repos...")
    subprocess.run(["pacman", "-Sy", "--noconfirm"], check=True)
    result = subprocess.run(["pacman", "-Si", "linux-cachyos"], capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(
            "CachyOS repos configured but linux-cachyos not found. "
            "Fix the network/mirror issue or set USE_CACHYOS = False."
        )


def create_disk_config(
    device_path: str,
    encryption_password: str | None = None,
) -> DiskLayoutConfiguration:
    """
    Create disk configuration programmatically.

    Layout:
    - /boot: 1 GiB FAT32 (EFI System Partition)
    - LUKS encrypted btrfs partition with subvolumes:
      - @          mounted at /
      - @home      mounted at /home
      - @snapshots mounted at /.snapshots
      - @var_log   mounted at /var/log
    """
    device_path = Path(device_path)

    # Get the physical device
    device = device_handler.get_device(device_path)
    if not device:
        raise ValueError(f"Device not found: {device_path}")

    sector_size = device.device_info.sector_size

    info(f"Configuring disk: {device_path}")
    info(f"  Total size: {device.device_info.total_size}")
    info(f"  Sector size: {sector_size}")

    # Create device modification (wipe the disk)
    device_mod = DeviceModification(device, wipe=True)

    # Boot partition: 1 GiB FAT32 at start
    boot_partition = PartitionModification(
        status=ModificationStatus.CREATE,
        type=PartitionType.PRIMARY,
        start=Size(1, Unit.MiB, sector_size),
        length=Size(BOOT_SIZE_GIB, Unit.GiB, sector_size),
        mountpoint=Path("/boot"),
        fs_type=FilesystemType.FAT32,
        flags=[PartitionFlag.BOOT, PartitionFlag.ESP],
    )
    device_mod.add_partition(boot_partition)

    # Calculate start position for the main partition (after boot)
    main_start = Size(1, Unit.MiB, sector_size) + Size(BOOT_SIZE_GIB, Unit.GiB, sector_size)

    # Main partition: rest of disk (LUKS encrypted btrfs with subvolumes)
    # Leave some space at the end for GPT backup header (1 MiB is safe)
    total_size = device.device_info.total_size
    end_reserved = Size(1, Unit.MiB, sector_size)
    main_length = total_size - main_start - end_reserved

    main_partition = PartitionModification(
        status=ModificationStatus.CREATE,
        type=PartitionType.PRIMARY,
        start=main_start,
        length=main_length,
        mountpoint=None,  # Subvolumes define mountpoints
        fs_type=FilesystemType.BTRFS,
        mount_options=["compress=zstd"],
        flags=[],
        btrfs_subvols=[
            SubvolumeModification(Path("@"), Path("/")),
            SubvolumeModification(Path("@home"), Path("/home")),
            SubvolumeModification(Path("@snapshots"), Path("/.snapshots")),
            SubvolumeModification(Path("@var_log"), Path("/var/log")),
        ],
    )
    device_mod.add_partition(main_partition)

    # Create disk layout configuration (no LVM)
    disk_config = DiskLayoutConfiguration(
        config_type=DiskLayoutType.Default,
        device_modifications=[device_mod],
    )

    # Setup encryption if password provided
    if encryption_password:
        disk_encryption = DiskEncryption(
            encryption_password=Password(plaintext=encryption_password),
            encryption_type=EncryptionType.LUKS,
            partitions=[main_partition],
            lvm_volumes=[],
        )
        disk_config.disk_encryption = disk_encryption

    return disk_config


def get_post_install_commands(users: list[str]) -> list[str]:
    """
    Generate post-installation commands for provisioning.

    These commands run inside the chroot environment after the base
    installation is complete.
    """
    commands = []

    # Configure NetworkManager to use iwd as the wifi backend
    commands.append("mkdir -p /etc/NetworkManager/conf.d")
    nm_iwd_config = r'''[device]
wifi.backend=iwd
'''
    commands.append(f"cat > /etc/NetworkManager/conf.d/iwd.conf << 'NM_EOF'\n{nm_iwd_config}NM_EOF")

    # Enable mDNS (.local) hostname resolution for network printers and other
    # zeroconf services. Idempotent: only inserts mdns_minimal if not present.
    commands.append(
        r"""grep -q mdns_minimal /etc/nsswitch.conf || """
        r"""sed -i 's/^\(hosts:.*mymachines\)\( \|$\)/\1 mdns_minimal [NOTFOUND=return]\2/' /etc/nsswitch.conf"""
    )

    # Install yay (AUR helper) - needs to be done as a non-root user
    # First, ensure base-devel and git are installed (should be from packages list)
    commands.append("pacman -S --noconfirm --needed base-devel git")

    # Enable passwordless sudo for wheel group (needed for makepkg/yay)
    commands.append("echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel-nopasswd")
    commands.append("chmod 440 /etc/sudoers.d/wheel-nopasswd")

    # Configure greetd with tuigreet
    # Create greetd config directory if it doesn't exist
    commands.append("mkdir -p /etc/greetd")

    # Write greetd config to use tuigreet with sway
    greetd_config = r'''[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd sway"
user = "greeter"
'''
    commands.append(f"cat > /etc/greetd/config.toml << 'GREETD_EOF'\n{greetd_config}GREETD_EOF")

    for username in users:
        # Set zsh as default shell
        commands.append(f"chsh -s /usr/bin/zsh {username}")

        # Install yay AUR helper (set TMPDIR for go builds)
        commands.append(f"su - {username} -c 'export TMPDIR=~/tmp && mkdir -p $TMPDIR && git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay && makepkg -si --noconfirm && rm -rf ~/yay ~/tmp'")

        # Clone dotfiles and run stow
        commands.append(
            f"su - {username} -c '"
            "git clone https://github.com/gammons/dotfiles ~/dotfiles && "
            "cd ~/dotfiles && "
            "stow -d ~/dotfiles -t ~ base"
            "'"
        )

        # Enable noctalia systemd user service (after dotfiles are stowed)
        commands.append(f"su - {username} -c 'systemctl --user enable noctalia.service || true'")

        # Set theme (after dotfiles are in place)
        commands.append(f"su - {username} -c 'source ~/.zshrc 2>/dev/null; changetheme nord || true'")

        # Install packer.nvim
        commands.append(
            f"su - {username} -c '"
            "git clone --depth 1 https://github.com/wbthomason/packer.nvim "
            "~/.local/share/nvim/site/pack/packer/start/packer.nvim"
            "'"
        )

    # Install AUR packages using yay (run as first non-root user)
    first_user = users[0] if users else None
    if first_user:
        commands.append(
            f"su - {first_user} -c 'yay -S --noconfirm google-chrome noctalia-shell slack-desktop spotify swayfx swaylock-effects'"
        )

    return commands


def perform_installation(
    creds_dict: dict,
    device_path: str,
    dry_run: bool = False,
) -> None:
    """Perform the automated installation."""

    # Get encryption password from credentials
    encryption_password = creds_dict.get("encryption_password")

    if USE_CACHYOS and not dry_run:
        setup_cachyos_repos()

    # Create disk configuration programmatically
    if not dry_run:
        info(f"Building disk configuration for {device_path}...")
        disk_config = create_disk_config(device_path, encryption_password)

    # Create locale configuration
    locale_config = LocaleConfiguration(
        kb_layout=KEYBOARD_LAYOUT,
        sys_lang=LOCALE_LANG,
        sys_enc=LOCALE_ENCODING,
    )

    # Create users from credentials file
    users_config = creds_dict.get("users", [])
    if not users_config:
        error("No users defined in credentials file!")
        sys.exit(1)

    # Groups that require packages to be installed first (package creates the group)
    deferred_groups = {"docker"}

    users = []
    user_deferred_groups = {}  # username -> list of groups to add later

    for u in users_config:
        username = u["username"]
        all_groups = u.get("groups", [])

        # Split groups into immediate and deferred
        immediate_groups = [g for g in all_groups if g not in deferred_groups]
        later_groups = [g for g in all_groups if g in deferred_groups]

        if later_groups:
            user_deferred_groups[username] = later_groups

        users.append(User(
            username=username,
            password=Password(plaintext=u.get("!password", u.get("password", ""))),
            sudo=u.get("sudo", False),
            groups=immediate_groups,
        ))

    usernames = [u["username"] for u in users_config]

    if dry_run:
        info("=== DRY RUN MODE ===")
        info(f"Target device: {device_path}")
        info(f"Mountpoint: {MOUNTPOINT}")
        info(f"Disk layout:")
        info(f"  - /boot: {BOOT_SIZE_GIB} GiB FAT32 (ESP)")
        info(f"  - LUKS encrypted btrfs (encrypted: {encryption_password is not None}):")
        info(f"    - @          -> /")
        info(f"    - @home      -> /home")
        info(f"    - @snapshots -> /.snapshots")
        info(f"    - @var_log   -> /var/log")
        info(f"    - mount options: compress=zstd")
        info(f"Hostname: {HOSTNAME}")
        info(f"Timezone: {TIMEZONE}")
        info(f"Locale: {LOCALE_LANG}")
        info(f"Kernels: {KERNELS}")
        if USE_CACHYOS:
            info("CachyOS: repos configured on live ISO via cachyos-repo.sh --install (auto-detected tier)")
            info("  - extra packages: cachyos-keyring, cachyos-mirrorlist")
        info(f"Bootloader: {BOOTLOADER.value} (UKI: {USE_UKI})")
        info(f"Packages ({len(PACKAGES)}): {', '.join(PACKAGES[:10])}...")
        info(f"Services: {', '.join(SERVICES)}")
        info(f"Users: {[u.username for u in users]}")
        info("Post-install provisioning:")
        info("  - Configure NetworkManager to use iwd as wifi backend")
        info("  - Configure and enable greetd with tuigreet")
        info("  - Set zsh as default shell for all users")
        info("  - Install yay AUR helper")
        info("  - Clone dotfiles and run stow")
        info("  - Enable noctalia systemd user service")
        info("  - Set theme to nord")
        info("  - Install packer.nvim")
        info("  - Install AUR packages: google-chrome, noctalia-shell, slack-desktop, spotify, swayfx, swaylock-effects")
        return

    # Build disk config for real installation
    disk_config = create_disk_config(device_path, encryption_password)

    info("Starting automated Arch Linux installation...")
    info(f"Target device: {device_path}")
    info(f"Target mountpoint: {MOUNTPOINT}")

    # Perform filesystem operations (format and partition disks)
    info("Setting up filesystems...")
    fs_handler = FilesystemHandler(disk_config)
    fs_handler.perform_filesystem_operations()

    # Determine if mkinitcpio should run (not needed if using UKI)
    run_mkinitcpio = not USE_UKI

    with Installer(
        MOUNTPOINT,
        disk_config,
        kernels=KERNELS,
    ) as installation:
        # Mount the filesystems
        if disk_config.config_type != DiskLayoutType.Pre_mount:
            installation.mount_ordered_layout()

        installation.sanity_check()

        # Generate encryption key files if needed
        if disk_config.config_type != DiskLayoutType.Pre_mount:
            if (
                disk_config.disk_encryption
                and disk_config.disk_encryption.encryption_type
                != EncryptionType.NO_ENCRYPTION
            ):
                installation.generate_key_files()

        # Perform minimal installation
        info("Installing base system...")
        installation.minimal_installation(
            mkinitcpio=run_mkinitcpio,
            hostname=HOSTNAME,
            locale_config=locale_config,
        )

        if USE_CACHYOS:
            ensure_cachyos_repos_in_target(MOUNTPOINT)

        # Setup swap (zram) - 4.2+ setup_swap only configures zram; arg is now
        # the compression algorithm (default ZramAlgorithm.ZSTD).
        info("Setting up swap...")
        installation.setup_swap()

        # Install bootloader
        info("Installing bootloader...")
        if BOOTLOADER == Bootloader.Grub:
            installation.add_additional_packages("grub")

        installation.add_bootloader(BOOTLOADER, USE_UKI)

        # Copy network config from ISO (use what's working now)
        info("Configuring network...")
        installation.copy_iso_network_config(enable_services=True)

        # Create users
        info("Creating users...")
        installation.create_users(users)

        # Install additional packages
        info("Installing additional packages...")
        packages = (["cachyos-keyring", "cachyos-mirrorlist"] if USE_CACHYOS else []) + PACKAGES
        installation.add_additional_packages(packages)

        # Add users to deferred groups (groups created by packages like docker)
        if user_deferred_groups:
            info("Adding users to package-created groups...")
            for username, groups in user_deferred_groups.items():
                for group in groups:
                    installation.arch_chroot(f"usermod -aG {group} {username}")

        # Set timezone
        info(f"Setting timezone to {TIMEZONE}...")
        installation.set_timezone(TIMEZONE)

        # Enable NTP
        installation.activate_time_synchronization()

        # Enable services
        if SERVICES:
            info("Enabling services...")
            installation.enable_service(SERVICES)

        # Enable greetd (display manager)
        info("Enabling greetd...")
        installation.enable_service("greetd")

        # Generate fstab - do this before optional provisioning so system is bootable
        info("Generating fstab...")
        installation.genfstab()

        # Run post-installation provisioning commands
        # These are optional - system should boot even if these fail
        info("Running post-installation provisioning...")
        post_install_commands = get_post_install_commands(usernames)
        try:
            run_custom_user_commands(post_install_commands, installation)
        except Exception as e:
            warn(f"Post-installation provisioning failed: {e}")
            warn("System should still be bootable. You can run provisioning manually after reboot.")

    info("=" * 60)
    info("Installation complete!")
    info("You may now reboot into your new Arch Linux system.")
    info("=" * 60)


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Automated Arch Linux installation with archinstall",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Disk Layout:
  The script creates the following layout on the target device:
  - /boot: 1 GiB FAT32 (EFI System Partition)
  - LUKS encrypted btrfs partition (if encryption_password set) with subvolumes:
    - @          mounted at /
    - @home      mounted at /home
    - @snapshots mounted at /.snapshots
    - @var_log   mounted at /var/log

Examples:
  # Dry run to see what would happen:
  python automated_install.py --dry-run --device /dev/sda

  # Install to /dev/nvme0n1:
  python automated_install.py --device /dev/nvme0n1
        """,
    )
    parser.add_argument(
        "--creds",
        type=Path,
        default=CREDS_PATH,
        help=f"Path to credentials JSON file (default: {CREDS_PATH})",
    )
    parser.add_argument(
        "--device",
        type=str,
        default=DEFAULT_DEVICE,
        help=f"Target device for installation (default: {DEFAULT_DEVICE})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )
    args = parser.parse_args()

    # Load credentials
    info(f"Loading credentials from {args.creds}...")
    creds_dict = load_credentials(args.creds)

    # Perform installation
    perform_installation(creds_dict, args.device, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
