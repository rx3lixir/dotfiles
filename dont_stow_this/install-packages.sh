#!/bin/bash

# System Setup Script
# This script installs paru AUR helper and then installs all required packages

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Starting System Setup ===${NC}\n"

# ============================================================================
# STEP 1: Install paru AUR helper
# ============================================================================

if command -v paru &> /dev/null; then
    echo -e "${YELLOW}paru is already installed, skipping...${NC}\n"
else
    echo -e "${GREEN}Installing paru AUR helper...${NC}"
    
    # Install dependencies for building paru
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone paru repository
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    
    # Build and install paru
    makepkg -si --noconfirm
    
    # Clean up
    cd ~
    rm -rf /tmp/paru
    
    echo -e "${GREEN}paru installed successfully!${NC}\n"
fi

# ============================================================================
# STEP 2: Update system
# ============================================================================

echo -e "${GREEN}Updating system...${NC}"
paru -Syu --noconfirm

# ============================================================================
# STEP 3: Install packages
# ============================================================================

echo -e "${GREEN}Installing all packages...${NC}\n"

# Base system packages
paru -S --needed --noconfirm \
    base \
    base-devel \
    linux \
    linux-firmware \
    linux-headers \
    sudo

# Bootloader and system tools
paru -S --needed --noconfirm \
    amd-ucode \
    efibootmgr \
    grub \
    grub-btrfs \
    os-prober \
    plymouth \

# Filesystem and snapshot management
paru -S --needed --noconfirm \
    btrfs-progs \
    snapper

# Network management
paru -S --needed --noconfirm \
    networkmanager \
    iwd

# Graphics drivers (AMD)
paru -S --needed --noconfirm \
    libva-mesa-driver \
    mesa \
    mesa-vdpau \
    vulkan-radeon

# Audio system
paru -S --needed --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-audio \
    pipewire-jack \
    pipewire-pulse \
    wireplumber

# Hyprland and Wayland components
paru -S --needed --noconfirm \
    hyprland \
    hyprcursor \
    hypridle \
    hyprlock \
    hyprpaper \
    hyprpolkitagent \
    hyprshot \
    waybar \
    wlogout

# XDG portals
paru -S --needed --noconfirm \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland

# Notifications and system overlays
paru -S --needed --noconfirm \
    swaync \
    swayosd

# Display manager and system utilities
paru -S --needed --noconfirm \
    brightnessctl \
    ly \
    playerctl \
    upower

# Bluetooth
paru -S --needed --noconfirm \
    bluez \
    bluez-utils \
    bluetui

# Terminal and shell
paru -S --needed --noconfirm \
    fish \
    kitty \
    starship \
    tmux \
    tmux-sessionizer

# Terminal utilities
paru -S --needed --noconfirm \
    bat \
    btop \
    cbonsai \
    eza \
    fzf \
    less \
    ripgrep \
    tree \
    yazi \
    zoxide

# Text editors
paru -S --needed --noconfirm \
    nano \
    neovim \

# File managers and viewers
paru -S --needed --noconfirm \
    evince \
    file-roller \
    loupe \
    nautilus \
    onlyoffice-bin

# Development tools - compilers and build tools
paru -S --needed --noconfirm \
    clang \
    cmake \
    git \
    make

# Development tools - languages and runtimes
paru -S --needed --noconfirm \
    bun-bin \
    go \
    nodejs \
    npm \
    rust

# Development tools - Docker
paru -S --needed --noconfirm \
    docker \
    docker-compose \
    lazydocker

# Development tools - database and TUI apps
paru -S --needed --noconfirm \
    lazygit \
    rainfrog

# Network utilities
paru -S --needed --noconfirm \
    curl \
    httpie \
    httpie-desktop-bin \
    openssh \
    wget \
    xray

# System security and monitoring
paru -S --needed --noconfirm \
    arch-audit \
    auto-cpufreq \
    earlyoom \
    fail2ban \
    smartmontools \
    ufw

# Compression tools
paru -S --needed --noconfirm \
    7zip \
    unrar \
    unzip

# Application launcher
paru -S --needed --noconfirm \
    rofi 

# Clipboard manager
paru -S --needed --noconfirm \
    clipse

# Screen recording
paru -S --needed --noconfirm \
    wl-screenrec

# Clipboard utilities
paru -S --needed --noconfirm \
    wl-clipboard

# Theming and appearance
paru -S --needed --noconfirm \
    adw-gtk-theme \
    adwaita-cursors \
    adwaita-fonts \
    fontconfig \
    freetype2 \
    matugen-bin \
    noto-fonts \
    papirus-icon-theme \
    phinger-cursors \
    ttf-apple-emoji \
    ttf-ubuntu-nerd \
    ttf-dejavu \
    ttf-times-new-roman \
    ttf-outfit

# Applications
paru -S --needed --noconfirm \
    localsend-bin \
    mpv \
    obsidian \
    qbittorrent \
    zen-browser-bin

# System utilities
paru -S --needed --noconfirm \
    grep \
    man-pages \
    pacman-contrib \
    paru \
    reflector \
    stow \
    strace \
    tldr \
    translate-shell \
    udev \
    zram-generator

# Keyboard remapping
paru -S --needed --noconfirm \
    kanata

# Misc utilities
paru -S --needed --noconfirm \
    impala \
    wiremix

# ============================================================================
# DONE
# ============================================================================

echo -e "\n${GREEN}=== Installation Complete! ===${NC}"
echo -e "${YELLOW}Note: You may need to reboot for some changes to take effect${NC}"
echo -e "${YELLOW}Don't forget to enable services like NetworkManager, Docker, etc.${NC}"
