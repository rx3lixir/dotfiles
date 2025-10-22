# Arch Linux Installation Guide

## Full Disk Encryption (LUKS) + Btrfs + Snapper

Please notice that this is just my guide and stay sceptical following it!

---

## Table of Contents

1. [Pre-Installation Setup](#pre-installation-setup)
2. [Disk Encryption & Partitioning](#disk-encryption--partitioning)
3. [Btrfs Subvolume Setup](#btrfs-subvolume-setup)
4. [Base System Installation](#base-system-installation)
5. [System Configuration](#system-configuration)
6. [Bootloader Setup](#bootloader-setup)
7. [User Management](#user-management)
8. [Post-Installation Setup](#post-installation-setup)
9. [Snapshot Management with Snapper](#snapshot-management-with-snapper)
10. [Performance Optimization](#performance-optimization)
11. [Development Environment](#development-environment)
12. [Additional Services](#additional-services)
13. [Troubleshooting](#troubleshooting)

---

## Pre-Installation Setup

### 1. Boot from USB and Verify UEFI Mode

```bash
# This should show files if you're in UEFI mode (which you want!)
ls /sys/firmware/efi/efivars

```

### 2. Adjust Screen Brightness (if needed)

```bash
# First, find your backlight device and check the max brightness
ls /sys/class/backlight/
cat /sys/class/backlight/*/max_brightness

# Set brightness (replace with your actual path and desired value)
echo 500 | sudo tee /sys/class/backlight/amdgpu_bl0/brightness

```

### 3. Connect to WiFi

```bash
# Start the interactive WiFi tool
iwctl

# Inside iwctl, run these commands:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YOUR_NETWORK_NAME"
exit

# Test your connection
ping -c 3 google.com

```

### 4. Sync System Clock

```bash
timedatectl set-ntp true
```

---

## Disk Encryption & Partitioning

**IMPORTANT**: We're setting up full disk encryption here. You'll need to enter a password every time you boot. Make it strong but memorable!

### 5. Identify Your Disk

```bash
# List all available disks - look for your main drive
lsblk
fdisk -l
```

**Note**: In this guide, we'll use `/dev/nvme0n1` as an example. **Replace this with your actual disk name!**

### 6. Partition Your Disk

```bash
# Open the partitioning tool for your disk
cfdisk /dev/nvme0n1
```

**Create these partitions:**

| Partition | Size | Type |
| --- | --- | --- |
| `/dev/nvme0n1p1` | 512MB | EFI System |
| `/dev/nvme0n1p2` | Remaining space | Linux filesystem |

**In cfdisk:**

1. Select `gpt` if asked for label type
2. Create new partition: 512M, type: EFI System
3. Create new partition: Use remaining space, type: Linux filesystem
4. Write changes (type "yes" to confirm)
5. Quit

### 7. Setup LUKS Encryption

**This is where we encrypt your main partition:**

```bash
# Format the partition as LUKS encrypted
# You'll be asked to create a password - 
# REMEMBER THIS PASSWORD!
cryptsetup luksFormat /dev/nvme0n1p2
```

**Type `YES` (in capitals) to confirm, then enter your encryption password twice.**

```bash
# Open the encrypted partition (you'll enter your password)
# "cryptroot" is just a name - the decrypted partition will appear as /dev/mapper/cryptroot
cryptsetup open /dev/nvme0n1p2 cryptroot

# Verify it's open
ls /dev/mapper/
# You should see "cryptroot" listed
```

### 8. Create Filesystems

```bash
# Format the EFI partition (the unencrypted boot partition)
mkfs.fat -F32 /dev/nvme0n1p1

# Create btrfs filesystem on the encrypted partition
mkfs.btrfs -L Archlinux /dev/mapper/cryptroot
```

---

## Btrfs Subvolume Setup

**Why subvolumes?** They let you snapshot different parts of your system independently and exclude certain directories (like temporary files) from snapshots.

### 9. Create Subvolumes

```bash
# Mount the btrfs filesystem temporarily
mount /dev/mapper/cryptroot /mnt

# Create all our subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@snapshots

# Unmount so we can remount with proper options
umount /mnt
```

**What each subvolume is for:**

- `@` - Your root filesystem (main system files)
- `@home` - Your personal files and settings
- `@log` - System logs (we don't need to snapshot these)
- `@pkg` - Pacman package cache (saves re-downloading)
- `@tmp` - Temporary files (definitely don't snapshot these!)
- `@snapshots` - Where snapper stores snapshots

### 10. Mount Everything with Optimal Settings

```bash
# Mount root subvolume with SSD-optimized options
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt

# Create all the mount point directories
mkdir -p /mnt/{home,var/log,var/cache/pacman/pkg,tmp,boot,.snapshots}

# Mount all the other subvolumes
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@pkg /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@tmp /dev/mapper/cryptroot /mnt/tmp
mount -o noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

# Mount the EFI boot partition
mount /dev/nvme0n1p1 /mnt/boot

# Verify everything is mounted correctly
lsblk
```

**What those mount options mean:**

- `noatime` - Don't update access times (faster)
- `compress=zstd:3` - Compress files to save space
- `ssd` - SSD-specific optimizations
- `discard=async` - Helps with SSD wear leveling
- `space_cache=v2` - Better free space tracking

---

## Base System Installation

### 11. Update Keyring and Install Base System

```bash
# Refresh the keyring (avoids signature errors)
pacman -Sy archlinux-keyring

# Install the base system (this will take a few minutes)
pacstrap /mnt base base-devel \
    linux linux-firmware linux-headers \
    btrfs-progs snapper grub-btrfs \
    amd-ucode networkmanager \
    grub efibootmgr os-prober \
    vim nano git curl wget btop \
    mesa vulkan-radeon libva-mesa-driver \
    mesa-vdpau make cmake
```

**What we're installing:**

- Base system and kernel
- Btrfs tools and snapshot utilities
- AMD microcode and graphics drivers
- Network management tools
- Bootloader (GRUB)
- Essential utilities

### 12. Generate Filesystem Table

```bash
# Generate fstab (tells the system what to mount on boot)
genfstab -U /mnt >> /mnt/etc/fstab

# Good practice: check it looks right
cat /mnt/etc/fstab
```

### 13. Enter Your New System

```bash
# Chroot into the new installation
# From now on, commands run inside your new system
arch-chroot /mnt
```

---

## System Configuration

### 14. Set Timezone and Locale

```bash
# Set your timezone (adjust for your location!)
# Find yours with: ls /usr/share/zoneinfo/
ln -sf /usr/share/zoneinfo/Asia/Barnaul /etc/localtime

hwclock --systohc

# Setup locales (languages)
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

```

### 15. Set Hostname

```bash
# Choose your computer's name (replace HOSTNAME with what you want)
echo "archlinux" > /etc/hostname

# Setup hosts file
cat >> /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF
```

**Replace `archlinux` with whatever name you chose!**

### 16. Set Root Password

```bash
# Set a password for the root user
passwd
```

---

## Bootloader Setup

**CRITICAL SECTION**: We need to configure GRUB to unlock your encrypted disk on boot.

### 17. Configure GRUB for Encryption

```bash
# Edit GRUB configuration
vim /etc/default/grub
```

**Find this line:**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

**Change it to** (replace UUID with your actual partition UUID - we'll get it in a moment):

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=YOUR-UUID-HERE:cryptroot root=/dev/mapper/cryptroot"
```

**To get your UUID, run this command in another terminal or write it down:**

```bash
blkid /dev/nvme0n1p2
```

Copy the UUID value (it looks like: `a1b2c3d4-e5f6-...`)

**Also in `/etc/default/grub`, uncomment this line:**

```bash
GRUB_ENABLE_CRYPTODISK=y
```

**And make sure this is uncommented:**

```bash
GRUB_DISABLE_OS_PROBER=false
```

### 18. Configure Initramfs for Encryption

```bash
# Edit mkinitcpio configuration
vim /etc/mkinitcpio.conf
```

**Find the MODULES line and change it to:**

```bash
MODULES=(btrfs)
```

**Find the HOOKS line and add `encrypt` before `filesystems`:**

```bash
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

**This is super important!** The order matters:

- `encrypt` must come before `filesystems`
- `keyboard` and `keymap` must come before `encrypt`

### 19. Rebuild Initramfs

```bash
# Generate the initramfs with our encryption settings
mkinitcpio -P
```

### 20. Install GRUB

```bash
# Install GRUB to the EFI partition
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

**You should see a message about detecting your encrypted device!**

### 21. Fix /tmp Cleanup Issue

Because `/tmp` is its own subvolume, we need to tell the system to clean it on boot:

```bash
# Create tmp cleanup configuration
mkdir -p /etc/tmpfiles.d
cat > /etc/tmpfiles.d/tmp.conf << 'EOF'
# Clean /tmp directory on every boot
D! /tmp 1777 root root 0
EOF
```

---

## User Management

### 22. Create Your User Account

```bash
# Create your user (replace USERNAME with your desired username)
useradd -m -G wheel,audio,video,optical,storage,input -s /bin/bash USERNAME

# Set password for your user
passwd USERNAME

# Give your user sudo privileges
EDITOR=nvim visudo
```

**In the visudo editor, uncomment this line:**

```bash
%wheel ALL=(ALL:ALL) ALL
```

Save and exit (in vim: press `Esc`, type `:wq`, press `Enter`)

### 23. Enable NetworkManager

```bash
# Enable NetworkManager so you have internet after reboot
systemctl enable NetworkManager
```

### 24. Exit and Reboot

```bash
# Exit the chroot environment
exit

# Unmount everything
umount -R /mnt

# Reboot into your new system!
reboot
```

**Remove the USB stick when rebooting!**

**You'll now see:**

1. GRUB menu
2. Password prompt for disk decryption (enter your LUKS password)
3. Login prompt (login with your username and password)

---

## Post-Installation Setup

Congratulations! You've installed Arch with encryption. Now let's set up the rest.

### 25. Connect to WiFi (if needed)

```bash
# Connect using NetworkManager
nmcli device wifi connect "YOUR_NETWORK_NAME" password "YOUR_PASSWORD"

# Test connection
ping -c 3 google.com
```

### 26. Setup Pacman Configuration

```bash
# Edit pacman configuration
sudo vim /etc/pacman.conf
```

**Uncomment or add these lines for a better experience:**

```bash
Color
ILoveCandy
ParallelDownloads = 10
```

Save and update:

```bash
sudo pacman -Syu
```

### 27. Setup Fast Mirrors with Reflector

```bash
# Install reflector
sudo pacman -S reflector

# Generate fast mirror list (adjust countries to your location)
sudo reflector --country Germany,France,Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Enable automatic mirror updates
sudo systemctl enable --now reflector.timer
```

### 28. Install AUR Helper (paru)

```bash
# Install dependencies
sudo pacman -S --needed base-devel git

# Clone paru
cd ~
git clone <https://aur.archlinux.org/paru.git>
cd paru

# Build and install
makepkg -si

# Clean up
cd ..
rm -rf paru
```

### 29. Install Essential Packages

**Development tools:**

```bash
sudo pacman -S docker \
docker-compose go nodejs \
npm pnpm rust
```

**Graphics and desktop environment:**

```bash
sudo pacman -S hyprland hyprlock hyprshot \
hyprpaper hypridle waybar xdg-desktop-portal-gtk \ 
xdg-desktop-portal-hyprland

sudo pacman -S brightnessctl bluez bluez-utils \
thunar kitty ly upower ttf-jetbrains-mono-nerd papirus-icon-theme adw-gtk-theme
```

**Audio:**

```bash
sudo pacman -S wireplumber pipewire pipewire-alsa \
pipewire-pulse pipewire-jack
```

**Utilities:**

```bash
sudo pacman -S 7zip unrar eza ripgrep stow tmux \
yazi zoxide openssh wl-clipboard hyprpicker \
cliphist inotify-tools app2unit trash-cli jq \
```

**AUR packages:**

```bash
paru -S xray ags-hyprpanel-git kanata \
tofi zen-browser-bin lazydocker auto-cpufreq \
caelestia-shell tmux-sessionizer qt5ct-kde qt6ct-kde
```

---

## Snapshot Management with Snapper

**This is where the magic happens - automated system snapshots!**

### 30. Initial Snapper Setup

```bash
# Verify your btrfs subvolumes
btrfs subvolume list /
```

You should see your subvolumes including `@snapshots`.

**Configure snapper with the existing @snapshots subvolume:**

```bash
# Make sure @snapshots is in fstab
sudo vim /etc/fstab
```

**Add this line if it's not there:**

```bash
/dev/mapper/cryptroot /.snapshots btrfs noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvol=@snapshots 0 0
```

**Mount it:**

```bash
sudo mount /.snapshots
```

### 31. Create Snapper Config (Important!)

**This is tricky because .snapshots already exists. Here's the fix:**

```bash
# 1. Temporarily unmount @snapshots
sudo umount /.snapshots

# 2. Remove the directory
sudo rmdir /.snapshots

# 3. Create snapper config (this works now!)
sudo snapper -c root create-config /

# 4. Delete the subvolume snapper just created (we want our @snapshots)
sudo btrfs subvolume delete /.snapshots

# 5. Recreate the directory
sudo mkdir /.snapshots

# 6. Mount our proper @snapshots
sudo mount /.snapshots

# 7. Verify everything works
sudo snapper -c root list
```

### 32. Configure Snapper Settings

```bash
# Edit snapper configuration
sudo vim /etc/snapper/configs/root
```

**Change these values:**

```bash
# Timeline creation
TIMELINE_CREATE="yes"
TIMELINE_MIN_AGE="1800"          # Create snapshots max every 30 min

# How many snapshots to keep
TIMELINE_LIMIT_HOURLY="12"       # Last 12 hours (detailed recent history)
TIMELINE_LIMIT_DAILY="7"         # Last 7 days
TIMELINE_LIMIT_WEEKLY="4"        # Last 4 weeks
TIMELINE_LIMIT_MONTHLY="3"       # Last 3 months
TIMELINE_LIMIT_YEARLY="0"        # No yearly snapshots

# Safety limits
NUMBER_LIMIT="30"                # Never exceed 30 snapshots
NUMBER_LIMIT_IMPORTANT="10"      # Keep up to 10 manual snapshots

# Cleanup settings
TIMELINE_CLEANUP="yes"
NUMBER_CLEANUP="yes"
EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="1800"

# Performance
BACKGROUND_COMPARISON="yes"
SYNC_ACL="yes"
```

### 33. Configure GRUB-Btrfs

```bash
# Edit grub-btrfs config
sudo vim /etc/default/grub-btrfs/config
```

**Add these lines:**

```bash
GRUB_BTRFS_SUBMENUNAME="Arch Snapshots"
GRUB_BTRFS_LIMIT="30"
```

### 34. Enable Snapshot Services

```bash
# Enable automatic snapshots
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer

# Enable automatic GRUB updates (so snapshots appear in boot menu)
sudo systemctl enable --now grub-btrfsd.service

# Create your first snapshot!
sudo snapper -c root create --description "Fresh Installation"

# Check it worked
sudo snapper -c root list
```

### 35. Add Helpful Aliases

```bash
# Edit your shell config
vim ~/.bashrc  # or ~/.zshrc if you use zsh
```

**Add these useful aliases:**

```bash
# Snapshot management aliases
alias snaplist='sudo snapper -c root list'
alias snapspace='btrfs filesystem usage / | grep -E "Used|Free"'
alias snapclean='sudo snapper -c root cleanup timeline && sudo snapper -c root cleanup number'

# Create manual snapshot with timestamp
snapnow() {
    sudo snapper -c root create --description "$1 - $(date '+%Y-%m-%d %H:%M')"
}

# Safe system update with snapshot
safe-update() {
    echo "Creating pre-update snapshot..."
    sudo snapper -c root create --description "Pre-update $(date '+%Y-%m-%d %H:%M')"
    echo "Updating system..."
    sudo pacman -Syu
    echo "Update complete!"
}
```

**Reload your shell:**

```bash
source ~/.bashrc
```

**Usage examples:**

```bash
# List all snapshots
snaplist

# Create a snapshot before making changes
snapnow "Before installing new software"

# Safe system update
safe-update

# Check disk usage
snapspace
```

---

## Performance Optimization

### 36. Setup Zram (Compressed RAM Swap)

```bash
# Install zram generator
sudo pacman -S zram-generator

# Configure zram
sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
EOF

# Reboot to enable (or systemctl daemon-reload && systemctl start systemd-zram-setup@zram0.service)
```

### 37. Install EarlyOOM (Prevents System Freezes)

```bash
# Install and enable EarlyOOM
sudo pacman -S earlyoom
sudo systemctl enable --now earlyoom
```

### 38. Enable Auto-CPUFreq (Laptop Battery Life)

```bash
# Already installed from AUR earlier
sudo systemctl enable --now auto-cpufreq
```

### 39. Check Boot Performance

```bash
# See how long your system takes to boot
systemd-analyze

# See what's taking time during boot
systemd-analyze blame
```

---

## Development Environment

### 40. Setup SSH Key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Display public key (add this to GitHub)
cat ~/.ssh/id_ed25519.pub
```

**Add the key to GitHub:** [https://github.com/settings/keys](https://github.com/settings/keys)

### 41. Configure Git

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"

# Better git output
git config --global color.ui auto
git config --global init.defaultBranch main
```

### 42. Setup Dotfiles (if you have them)

```bash
# Clone your dotfiles
cd ~
git clone git@github.com:yourusername/dotfiles.git
cd dotfiles

# Use stow to symlink configs
stow */
```

---

## Additional Services

### 43. Enable Docker

```bash
# Enable Docker service
sudo systemctl enable --now docker

# Add your user to docker group (so you don't need sudo)
sudo usermod -aG docker $USER

# You'll need to log out and back in for this to take effect
```

### 44. Setup Display Manager (LY)

```bash
# Enable LY display manager
sudo systemctl enable ly.service
```

### 45. Configure Kanata (Keyboard Remapping)

```bash
# Create necessary groups
sudo groupadd -r uinput
sudo usermod -aG input,uinput $USER

# Create udev rules
sudo tee /etc/udev/rules.d/99-uinput.rules << 'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

# Apply udev changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo modprobe uinput

# Make uinput load on boot
echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf

# Enable kanata service
systemctl --user enable kanata
```

**You'll need to create your kanata config at:** `~/.config/kanata/config.kbd`
