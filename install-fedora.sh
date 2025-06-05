#!/bin/bash

# Fedora Setup Script for Development Environment
# This script installs all the necessary packages for a complete development setup

set -e

echo "🚀 Starting Fedora development environment setup..."

# Check if running on Fedora
if ! grep -q "Fedora" /etc/os-release; then
    echo "❌ This script is designed for Fedora. Exiting."
    exit 1
fi

echo "📦 Installing basic development tools..."
sudo dnf install -y git neovim tig tmux htop the_silver_searcher fd-find fzf jq unzip keychain bat gh bind-utils nnn

echo "🖥️  Installing WM utilities and system tools..."
sudo dnf install -y kitty dunst NetworkManager network-manager-applet waybar wofi cpupower chrony

echo "🔊 Installing audio and bluetooth packages..."
sudo dnf install -y pavucontrol pulseaudio-utils bluez bluez-tools

echo "🪟 Installing Sway and related packages..."
sudo dnf install -y sway swaylock swayidle swaybg xdg-desktop-portal-wlr brightnessctl

echo "📸 Installing screenshot and display utilities..."
sudo dnf install -y slurp grim wl-clipboard gammastep light

echo "🎨 Installing fonts and additional utilities..."
sudo dnf install -y google-noto-emoji-fonts google-noto-sans-fonts wireplumber polkit pcmanfm swappy

echo "🐳 Installing developer tools..."
sudo dnf install -y docker docker-compose postgresql mysql redis kubernetes-client awscli2

echo "⚙️  Enabling and starting Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "🔒 Configuring SELinux for Docker containers..."
sudo setsebool -P container_manage_cgroup true

echo "🔨 Installing C/C++ development tools..."
sudo dnf install -y gcc gcc-c++ make automake autoconf libtool glibc-devel

echo "💎 Installing Ruby development dependencies..."
sudo dnf install -y perl-core perl-FindBin perl-IPC-Cmd zlib-devel libffi-devel libyaml-devel readline-devel mariadb-devel

sudo dnf install gtk3-devel atk-devel pango-devel gdk-pixbuf2-devel cairo-devel libdbusmenu-devel ruby-devel @development-tools
sudo dnf install gcc bison openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
sudo dnf install libdbusmenu-gtk3-devel gtk-layer-shell-devel

echo "⭐ Installing Starship prompt..."
mkdir -p ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin --yes

echo "🔧 Installing k9s (Kubernetes CLI manager)..."
curl -sL https://github.com/derailed/k9s/releases/download/v0.32.6/k9s_Linux_amd64.tar.gz -o /tmp/k9s.tar.gz
tar -xzf /tmp/k9s.tar.gz -C /tmp && sudo cp /tmp/k9s /usr/local/bin/
rm -f /tmp/k9s.tar.gz /tmp/k9s

echo "⏰ Enabling time synchronization..."
sudo systemctl enable systemd-timesyncd

echo "✅ Fedora development environment setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Log out and back in for Docker group changes to take effect"
echo "2. Install Flatpak applications:"
echo "   flatpak install -y flathub com.slack.Slack"
echo "   flatpak install -y flathub md.obsidian.Obsidian"
echo "   flatpak install -y flathub com.spotify.Client"
echo "3. Install asdf and your preferred language runtimes"
echo "4. Run 'npm install -g diagnostic-languageserver vscode-langservers-extracted' for vim LSP"
echo "5. For Ruby development: 'gem install rubocop-performance rubocop-rails rubocop-rspec'"
echo ""
echo "🐳 Docker troubleshooting:"
echo "If you encounter permission denied errors with docker-compose, run:"
echo "   sudo chcon -Rt svirt_sandbox_file_t /path/to/your/project"
echo "   chmod +x entrypoints/*.sh bin/*"
