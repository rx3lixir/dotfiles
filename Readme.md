# Arch Linux Installation Guide

## Full Disk Encryption (LUKS) + Btrfs + Snapper

**Warning**: This guide involves disk partitioning and encryption. Double-check every command before running it. Data loss is permanent!

---

## Table of Contents

1. [Pre-Installation Setup](#pre-installation-setup)
2. [Disk Encryption & Partitioning](#disk-encryption--partitioning)
3. [Btrfs Subvolume Setup](#btrfs-subvolume-setup)
4. [Base System Installation](#base-system-installation)
5. [System Configuration](#system-configuration)
6. [Bootloader Setup](#bootloader-setup)
7. [User Management](#user-management)
8. [First Boot & Package Installation](#first-boot--package-installation)
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

**CRITICAL**: We're setting up full disk encryption. You'll need to enter a password every time you boot. Make it strong but memorable!

### 5. Identify Your Disk

```bash
# List all available disks - look for your main drive
lsblk
fdisk -l
```

**IMPORTANT**: Throughout this guide, we use `/dev/[YOUR_DISK]` as a placeholder. Common disk names:
- NVMe SSD: `/dev/nvme0n1`
- SATA SSD/HDD: `/dev/sda`
- Additional drives: `/dev/nvme1n1`, `/dev/sdb`, etc.

**Write down your actual disk name and replace `/dev/[YOUR_DISK]` with it in every command!**

### 6. Partition Your Disk

```bash
# VERIFY THE DISK NAME FIRST!
lsblk

# Open the partitioning tool for your disk
cfdisk /dev/[YOUR_DISK]
```

**Create these partitions:**

| Partition | Size | Type |
| --- | --- | --- |
| `/dev/[YOUR_DISK]p1` or `/dev/[YOUR_DISK]1` | 512MB | EFI System |
| `/dev/[YOUR_DISK]p2` or `/dev/[YOUR_DISK]2` | Remaining space | Linux filesystem |

**Note**: NVMe drives use `p1`, `p2` (e.g., `nvme0n1p1`). SATA drives use `1`, `2` (e.g., `sda1`).

**In cfdisk:**

1. Select `gpt` if asked for label type
2. Create new partition: 512M, type: EFI System
3. Create new partition: Use remaining space, type: Linux filesystem
4. Write changes (type "yes" to confirm)
5. Quit

### 7. Setup LUKS Encryption

**This is where we encrypt your main partition:**

```bash
# DOUBLE CHECK YOUR PARTITION NUMBER!
lsblk

# Format the partition as LUKS encrypted
# You'll be asked to create a password - REMEMBER THIS PASSWORD!
cryptsetup luksFormat /dev/[YOUR_DISK]p2  # or /dev/[YOUR_DISK]2 for SATA
```

**Type `YES` (in capitals) to confirm, then enter your encryption password twice.**

```bash
# Open the encrypted partition (you'll enter your password)
# "cryptroot" is just a name - the decrypted partition will appear as /dev/mapper/cryptroot
cryptsetup open /dev/[YOUR_DISK]p2 cryptroot  # or /dev/[YOUR_DISK]2 for SATA

# Verify it's open
ls /dev/mapper/
# You should see "cryptroot" listed
```

### 8. Create Filesystems

```bash
# Format the EFI partition (the unencrypted boot partition)
mkfs.fat -F32 /dev/[YOUR_DISK]p1  # or /dev/[YOUR_DISK]1 for SATA

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
mount /dev/[YOUR_DISK]p1 /mnt/boot  # or /dev/[YOUR_DISK]1 for SATA

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
    vim nano git curl wget \
    mesa vulkan-radeon libva-mesa-driver \
    mesa-vdpau make cmake
```

**What we're installing:**

- Base system and kernel
- Btrfs tools and snapshot utilities
- AMD microcode and graphics drivers
- Network management tools
- Bootloader (GRUB)
- Essential build tools and utilities

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
# Choose your computer's name (replace with what you want)
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

### 17. Get Your Partition UUID

```bash
# Get the UUID of your encrypted partition
# Write this down or keep this terminal open!
blkid /dev/[YOUR_DISK]p2  # or /dev/[YOUR_DISK]2 for SATA
```

Copy the UUID value (it looks like: `a1b2c3d4-e5f6-...`)

### 18. Configure GRUB for Encryption

```bash
# Edit GRUB configuration
vim /etc/default/grub
```

**Find this line:**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
```

**Change it to** (replace YOUR-UUID-HERE with the UUID you just copied):

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=YOUR-UUID-HERE:cryptroot root=/dev/mapper/cryptroot"
```

**Also in `/etc/default/grub`, uncomment this line:**

```bash
GRUB_ENABLE_CRYPTODISK=y
```

**And make sure this is uncommented:**

```bash
GRUB_DISABLE_OS_PROBER=false
```

Save and exit (in vim: press `Esc`, type `:wq`, press `Enter`)

### 19. Configure Initramfs for Encryption

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

Save and exit.

### 20. Rebuild Initramfs

```bash
# Generate the initramfs with our encryption settings
mkinitcpio -P
```

### 21. Install GRUB

```bash
# Install GRUB to the EFI partition
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

**You should see a message about detecting your encrypted device!**

### 22. Fix /tmp Cleanup Issue

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

### 23. Create Your User Account

```bash
# Create your user (replace USERNAME with your desired username)
useradd -m -G wheel,audio,video,optical,storage,input -s /bin/bash USERNAME

# Set password for your user
passwd USERNAME

# Give your user sudo privileges
EDITOR=vim visudo
```

**In the visudo editor, uncomment this line:**

```bash
%wheel ALL=(ALL:ALL) ALL
```

Save and exit (in vim: press `Esc`, type `:wq`, press `Enter`)

### 24. Enable NetworkManager

```bash
# Enable NetworkManager so you have internet after reboot
systemctl enable NetworkManager
```

### 25. Exit and Reboot

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

## First Boot & Package Installation

Congratulations! You've installed Arch with encryption. Now let's set up everything else.

### 26. Connect to WiFi (if needed)

```bash
# Connect using NetworkManager
nmcli device wifi connect "YOUR_NETWORK_NAME" password "YOUR_PASSWORD"

# Test connection
ping -c 3 google.com
```

### 27. Setup Pacman Configuration

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

### 28. Setup Fast Mirrors with Reflector

```bash
# Install reflector
sudo pacman -S reflector

# Generate fast mirror list (adjust countries to your location)
sudo reflector --country Germany,France,Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Enable automatic mirror updates
sudo systemctl enable --now reflector.timer
```

### 29. Run the Package Installation Script

**Now we'll install paru and all your packages using the installation script.**

Create a file called `install-packages.sh`:

```bash
nano install-packages.sh
```

Copy the installation script contents (see the separate artifact), save and exit (Ctrl+X, Y, Enter).

Make it executable and run it:

```bash
chmod +x install-packages.sh
./install-packages.sh
```

**This will:**
1. Install paru (AUR helper)
2. Install ALL your packages using paru (both official repos and AUR)
3. Show you progress as it goes

**Note**: This will take a while! Go grab a coffee. The script will ask for your password and might ask for confirmation on some AUR packages.

### 30. Configure Bash Aliases

```bash
# Edit your bash config
nano ~/.bashrc
```

**Add these useful aliases at the end:**

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
    sudo paru -Syu
    echo "Update complete!"
}

# Better ls with eza
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias lt='eza --tree --icons'
```

**Reload your shell:**

```bash
source ~/.bashrc
```

---

## Snapshot Management with Snapper

**This is where the magic happens - automated system snapshots!**

### 31. Initial Snapper Setup

```bash
# Verify your btrfs subvolumes
btrfs subvolume list /
```

You should see your subvolumes including `@snapshots`.

### 32. Create Snapper Config

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

### 33. Configure Snapper Settings

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
TIMELINE_LIMIT_HOURLY="12"       # Last 12 hours
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

### 34. Configure GRUB-Btrfs

```bash
# Edit grub-btrfs config
sudo vim /etc/default/grub-btrfs/config
```

**Add these lines:**

```bash
GRUB_BTRFS_SUBMENUNAME="Arch Snapshots"
GRUB_BTRFS_LIMIT="30"
```

### 35. Enable Snapshot Services

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

---

## Performance Optimization

### 36. Setup Zram (Compressed RAM Swap)

```bash
# Configure zram
sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
EOF

# Enable it
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

### 37. Enable EarlyOOM (Prevents System Freezes)

```bash
# Enable EarlyOOM (already installed from script)
sudo systemctl enable --now earlyoom
```

### 38. Enable Auto-CPUFreq (Battery Life)

```bash
# Enable auto-cpufreq (already installed from script)
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

**Add the key to GitHub:** https://github.com/settings/keys

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

---

## Essential Security Setup

**IMPORTANT**: Your system is encrypted, which is great, but we need to add more layers of security.

### 46. Install Security Essentials

```bash
# Install security packages
sudo pacman -S ufw fail2ban arch-audit apparmor
```

### 47. Setup Firewall (UFW)

UFW (Uncomplicated Firewall) is the easiest way to manage iptables.

```bash
# Enable UFW
sudo systemctl enable --now ufw

# Set default policies (deny all incoming, allow all outgoing)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH if you use it (otherwise you'll lock yourself out remotely!)
sudo ufw allow ssh
# Or specify a custom SSH port if you changed it:
# sudo ufw allow 2222/tcp

# Allow other services you might need:
# sudo ufw allow 80/tcp      # HTTP
# sudo ufw allow 443/tcp     # HTTPS
# sudo ufw allow 8080/tcp    # Development server

# Enable the firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

**Testing UFW:**
```bash
# List all rules
sudo ufw status numbered

# Delete a rule by number if needed
sudo ufw delete [number]

# Disable UFW temporarily if something breaks
sudo ufw disable
```

### 48. Harden SSH Configuration

If you use SSH (especially if exposed to the internet):

```bash
# Backup the original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
sudo vim /etc/ssh/sshd_config
```

**Add or modify these lines:**

```bash
# Disable root login (use your user + sudo instead)
PermitRootLogin no

# Use SSH keys only, disable password authentication
PasswordAuthentication no
PubkeyAuthentication yes

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3

# Disconnect if no successful login within 30 seconds
LoginGraceTime 30

# Disable X11 forwarding if you don't need it
X11Forwarding no

# Use only strong ciphers and MACs
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Optional: Change default port (security through obscurity, but helps reduce noise)
# Port 2222

# Optional: Limit which users can SSH
# AllowUsers yourusername
```

**Restart SSH to apply changes:**

```bash
sudo systemctl restart sshd

# Verify config is valid
sudo sshd -t
```

**CRITICAL**: Test SSH access in a new terminal before closing your current session!

### 49. Setup Fail2Ban

Fail2Ban automatically bans IPs that show malicious signs (too many password failures, etc.)

```bash
# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit the config
sudo vim /etc/fail2ban/jail.local
```

**Find and modify these sections:**

```ini
[DEFAULT]
# Ban for 1 hour
bantime = 3600

# Check for failures over 10 minutes
findtime = 600

# Ban after 5 failures
maxretry = 5

# Email notifications (optional)
# destemail = your@email.com
# sendername = Fail2Ban
# action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
# If you changed SSH port:
# port = 2222
```

**Enable and start Fail2Ban:**

```bash
sudo systemctl enable --now fail2ban

# Check status
sudo fail2ban-client status

# Check SSH jail specifically
sudo fail2ban-client status sshd

# Unban an IP if you accidentally locked yourself out
sudo fail2ban-client set sshd unbanip [IP_ADDRESS]
```

### 50. Enable AppArmor

AppArmor provides Mandatory Access Control (MAC) security.

```bash
# Enable AppArmor in GRUB
sudo vim /etc/default/grub
```

**Add `apparmor=1 security=apparmor` to the kernel parameters:**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=YOUR-UUID-HERE:cryptroot root=/dev/mapper/cryptroot apparmor=1 security=apparmor"
```

**Rebuild GRUB and reboot:**

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

**After reboot, verify AppArmor is working:**

```bash
sudo aa-enabled
# Should return: "Yes"

# Check status
sudo systemctl status apparmor

# List loaded profiles
sudo aa-status
```

**Enable more AppArmor profiles:**

```bash
# Enable all available profiles in enforce mode
sudo aa-enforce /etc/apparmor.d/*

# Or enable specific profiles
sudo aa-enforce /etc/apparmor.d/usr.bin.firefox

# Set a profile to complain mode (logs violations but doesn't block)
sudo aa-complain /etc/apparmor.d/usr.bin.firefox
```

### 51. Configure Automatic Security Updates Check

```bash
# Install audit tool (already installed in step 46)
# Run security audit
arch-audit

# Create a weekly check timer
sudo tee /etc/systemd/system/arch-audit.timer << 'EOF'
[Unit]
Description=Weekly Arch Linux security audit

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Create the service
sudo tee /etc/systemd/system/arch-audit.service << 'EOF'
[Unit]
Description=Check for security updates

[Service]
Type=oneshot
ExecStart=/usr/bin/arch-audit
EOF

# Enable the timer
sudo systemctl enable --now arch-audit.timer
```

### 52. Additional Security Hardening

**Secure shared memory:**

```bash
# Edit fstab
sudo vim /etc/fstab

# Add this line at the end:
tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid 0 0

# Remount without rebooting
sudo mount -o remount /dev/shm
```

**Restrict access to kernel logs:**

```bash
# Add to sysctl config
sudo tee /etc/sysctl.d/50-dmesg-restrict.conf << 'EOF'
kernel.dmesg_restrict = 1
EOF

# Apply immediately
sudo sysctl -p /etc/sysctl.d/50-dmesg-restrict.conf
```

**Protect against IP spoofing:**

```bash
sudo tee /etc/sysctl.d/50-ip-spoof-protect.conf << 'EOF'
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
EOF

sudo sysctl -p /etc/sysctl.d/50-ip-spoof-protect.conf
```

**Disable uncommon network protocols:**

```bash
sudo tee /etc/modprobe.d/uncommon-network-protocols.conf << 'EOF'
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF
```

### 53. USB Security (Optional but Recommended)

If you're concerned about malicious USB devices:

```bash
# Install USBGuard
sudo pacman -S usbguard

# Generate initial policy based on current devices
sudo usbguard generate-policy > /tmp/rules.conf
sudo install -m 0600 /tmp/rules.conf /etc/usbguard/rules.conf

# Enable and start
sudo systemctl enable --now usbguard
sudo systemctl enable --now usbguard-dbus

# Check status
sudo usbguard list-devices
```

**USBGuard usage:**

```bash
# Allow a device permanently
sudo usbguard allow-device [device-id]

# Block a device
sudo usbguard block-device [device-id]

# Reject and remove device
sudo usbguard reject-device [device-id]
```

### 54. Security Checklist

After completing security setup, verify:

```bash
# ✓ Firewall is active
sudo ufw status

# ✓ Fail2Ban is running
sudo systemctl status fail2ban

# ✓ AppArmor is enabled
sudo aa-enabled

# ✓ SSH is hardened (if you use it)
sudo sshd -t

# ✓ No known vulnerabilities
arch-audit

# ✓ Check listening ports
sudo ss -tulpn

# ✓ Review recent login attempts
sudo journalctl -u sshd | tail -50
```

---

## System Maintenance

Proper maintenance keeps your system running smoothly and prevents issues.

### 55. Install Maintenance Tools

```bash
sudo pacman -S pacman-contrib pkgfile man-db man-pages tldr
```

### 56. Setup Automatic Pacman Cache Cleaning

The package cache in `/var/cache/pacman/pkg/` can grow huge over time.

```bash
# Check current cache size
du -sh /var/cache/pacman/pkg/

# Clean cache manually (keeps last 3 versions of each package)
sudo paccache -r

# Remove all uninstalled packages from cache
sudo paccache -ruk0
```

**Automate cache cleaning:**

```bash
# Enable the weekly timer to keep only last 3 versions
sudo systemctl enable --now paccache.timer

# Check when it will run next
systemctl list-timers paccache.timer
```

**Alternative: More aggressive cleaning:**

```bash
# Create a more aggressive cleanup service
sudo tee /etc/systemd/system/paccache-aggressive.service << 'EOF'
[Unit]
Description=Clean pacman cache aggressively

[Service]
Type=oneshot
ExecStart=/usr/bin/paccache -rk1
ExecStart=/usr/bin/paccache -ruk0
EOF

# Create timer for monthly execution
sudo tee /etc/systemd/system/paccache-aggressive.timer << 'EOF'
[Unit]
Description=Monthly aggressive pacman cache cleanup

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl enable --now paccache-aggressive.timer
```

### 57. Setup Journal Log Rotation

Systemd journals can consume a lot of space.

```bash
# Check current journal size
journalctl --disk-usage

# Configure journal size limits
sudo vim /etc/systemd/journald.conf
```

**Modify these lines:**

```ini
[Journal]
SystemMaxUse=500M
SystemMaxFileSize=50M
MaxRetentionSec=2week
```

**Apply changes:**

```bash
sudo systemctl restart systemd-journald

# Manually clean old logs if needed
sudo journalctl --vacuum-size=500M
sudo journalctl --vacuum-time=2weeks
```

### 58. Setup Automatic TRIM for SSD

TRIM keeps your SSD healthy and performant.

```bash
# Check if TRIM is supported
sudo hdparm -I /dev/[YOUR_DISK] | grep TRIM

# Enable weekly TRIM timer
sudo systemctl enable --now fstrim.timer

# Check when it runs next
systemctl list-timers fstrim.timer

# Manually run TRIM now
sudo fstrim -av
```

**Verify TRIM is working:**

```bash
# Check TRIM status on btrfs
sudo btrfs filesystem usage /

# After running fstrim, check logs
sudo journalctl -u fstrim
```

### 59. Monitor System Health

**Create a system health check script:**

```bash
# Create the script
sudo tee /usr/local/bin/system-health-check << 'EOF'
#!/bin/bash

echo "=== System Health Check ==="
echo

echo "=== Disk Usage ==="
df -h | grep -E '^/dev/|Filesystem'
echo

echo "=== Btrfs Usage ==="
sudo btrfs filesystem usage / 2>/dev/null || echo "Not available"
echo

echo "=== Memory Usage ==="
free -h
echo

echo "=== Failed Services ==="
systemctl --failed
echo

echo "=== Recent Errors in Journal ==="
journalctl -p err -b --no-pager | tail -20
echo

echo "=== Security Vulnerabilities ==="
arch-audit
echo

echo "=== Package Updates Available ==="
checkupdates
echo

echo "=== Snapshot Count ==="
sudo snapper -c root list | wc -l
echo

echo "Health check complete!"
EOF

# Make executable
sudo chmod +x /usr/local/bin/system-health-check

# Run it
sudo system-health-check
```

**Create an alias for easy access:**

```bash
echo "alias health='sudo system-health-check'" >> ~/.bashrc
source ~/.bashrc
```

### 60. Setup Weekly Maintenance Timer

```bash
# Create maintenance script
sudo tee /usr/local/bin/weekly-maintenance << 'EOF'
#!/bin/bash

echo "=== Starting Weekly Maintenance ==="
date

# Clean package cache (keep last version)
echo "Cleaning package cache..."
paccache -rk1
paccache -ruk0

# Clean journal logs
echo "Cleaning journal logs..."
journalctl --vacuum-time=2weeks

# Run TRIM
echo "Running TRIM..."
fstrim -av

# Check for failed services
echo "Checking for failed services..."
systemctl --failed

# Security audit
echo "Running security audit..."
arch-audit

echo "=== Maintenance Complete ==="
EOF

sudo chmod +x /usr/local/bin/weekly-maintenance

# Create systemd service
sudo tee /etc/systemd/system/weekly-maintenance.service << 'EOF'
[Unit]
Description=Weekly system maintenance

[Service]
Type=oneshot
ExecStart=/usr/local/bin/weekly-maintenance
EOF

# Create timer
sudo tee /etc/systemd/system/weekly-maintenance.timer << 'EOF'
[Unit]
Description=Run weekly system maintenance

[Timer]
OnCalendar=Sun 03:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable timer
sudo systemctl enable --now weekly-maintenance.timer
```

### 61. Monitor Disk SMART Status

Keep an eye on your disk health:

```bash
# Install smartmontools
sudo pacman -S smartmontools

# Check disk health
sudo smartctl -a /dev/[YOUR_DISK]

# Look for these important values:
# - Reallocated_Sector_Ct (should be 0 or very low)
# - Current_Pending_Sector (should be 0)
# - Offline_Uncorrectable (should be 0)

# Enable SMART monitoring
sudo systemctl enable --now smartd

# Configure email alerts (optional)
sudo vim /etc/smartd.conf
```

**Add this line for your disk:**

```bash
/dev/[YOUR_DISK] -a -o on -S on -s (S/../.././02|L/../../6/03)
```

This runs short self-test daily at 2 AM, long test weekly on Saturday at 3 AM.

### 62. Setup Orphaned Package Cleanup

Remove packages that were installed as dependencies but are no longer needed:

```bash
# List orphaned packages
pacman -Qtdq

# Remove them
sudo pacman -Rns $(pacman -Qtdq)
```

**Automate this:**

```bash
# Add to weekly maintenance script
sudo vim /usr/local/bin/weekly-maintenance

# Add before the final "Maintenance Complete" line:
echo "Removing orphaned packages..."
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    pacman -Rns --noconfirm $orphans
else
    echo "No orphaned packages found"
fi
```

### 63. File System Check Schedule

Btrfs has built-in scrubbing to detect and fix errors:

```bash
# Create btrfs scrub service
sudo tee /etc/systemd/system/btrfs-scrub@.service << 'EOF'
[Unit]
Description=Btrfs scrub on %f

[Service]
Type=oneshot
ExecStart=/usr/bin/btrfs scrub start -B %f
EOF

# Create monthly timer
sudo tee /etc/systemd/system/btrfs-scrub@-.timer << 'EOF'
[Unit]
Description=Monthly Btrfs scrub on /

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable the timer
sudo systemctl enable --now btrfs-scrub@-.timer

# Manually run scrub
sudo btrfs scrub start /

# Check scrub status
sudo btrfs scrub status /
```

### 64. Update Mirrorlist Regularly

Keep your mirrors fast and up to date:

```bash
# Reflector should already be set up from step 28
# Verify it's running
systemctl status reflector.timer

# Check when it will run next
systemctl list-timers reflector.timer

# Manually update mirrors now
sudo reflector --country Germany,France,Netherlands --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### 65. Monitor System Logs

Create shortcuts for common log checks:

```bash
# Add to ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# Log monitoring aliases
alias logboot='journalctl -b'                    # Current boot logs
alias logerr='journalctl -p err -b'              # Only errors this boot
alias logfail='systemctl --failed'               # Failed services
alias logssh='sudo journalctl -u sshd -n 50'     # Last 50 SSH logs
alias logfw='sudo journalctl -u ufw -n 50'       # Last 50 firewall logs

# System maintenance aliases
alias cleanup='sudo paccache -r && sudo paccache -ruk0 && journalctl --vacuum-time=2weeks'
alias orphans='pacman -Qtdq'
alias syshealth='sudo system-health-check'
EOF

source ~/.bashrc
```

### 66. Maintenance Checklist

**Daily (automatic):**
- ✓ Btrfs snapshots (snapper)
- ✓ Security audit check

**Weekly (automatic):**
- ✓ Package cache cleanup
- ✓ Journal log rotation
- ✓ TRIM operation
- ✓ Orphaned package removal

**Monthly (automatic):**
- ✓ Btrfs scrub
- ✓ Mirror list update

**Manual (as needed):**
```bash
# Check system health
health

# Update system with snapshot
safe-update

# Check for errors
logerr

# Clean up disk space
cleanup

# Check SMART status
sudo smartctl -a /dev/[YOUR_DISK]

# Review security
arch-audit
sudo ufw status
sudo fail2ban-client status
```

---

## Backup Strategy

**CRITICAL**: Snapshots are NOT backups! They protect against mistakes but not hardware failure, theft, or catastrophic damage.

### 67. Why You Need Backups

Btrfs snapshots protect you from:
- ✓ Accidental file deletion
- ✓ Bad system updates
- ✓ Configuration mistakes

Snapshots do NOT protect you from:
- ✗ Disk failure
- ✗ Filesystem corruption
- ✗ Physical damage (fire, water, theft)
- ✗ Ransomware (sophisticated attacks)

---

**That's it! You now have a fully encrypted Arch Linux system with automatic snapshots and all your development tools ready to go.**

Remember to:
- Create regular snapshots before major changes
- Keep your system updated with `safe-update`
- Back up your encryption password somewhere safe
- Test booting into snapshots from GRUB menu occasionally

Enjoy your new system!
