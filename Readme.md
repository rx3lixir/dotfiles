# Полный гайд по установке Arch Linux с btrfs и snapper

## Пакеты

### Системные

```bash
pacman -Syu amd-ucode base base devel btrfs-progs efibootmgr grub linux linux-firmware linux-headers os-prober zram-generator vim
```

```bash
sudo pacman -Syu mesa vulkan-radeon libva-mesa-driver mesa-vdpau xf86-video-amdgpu
```

```bash
sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si
```

---

```bash
sudo pacman -Syu git wget curl make cmake networkmanager openssh snapper snap-pac zsh
```

```bash
sudo pacman -Syu 7zip btop eza grep ripgrep stow tmux tree unrar yazi zoxide nvim
```

```bash
sudo pacman -Syu brightnessctl bluez bluez-utils thunar kitty ly upower wl-clipboard wf-recorder
```

```bash
sudo pacman -Syu hyprland hyprlock hyprshot hyprpolkitagent hypridle hyprpaper hyprpicker xdg-desktop-portal-hyprland
```

```bash
sudo pacman -Syu wireplumber pipewire pipewire-alsa pipewire-pulse pipewire-jack
```

```bash
sudo pacman -Syu dart-sass libgtop gvfs gtksourceview3 libsoup3 swwwt qt5-wayland qt6-wayland
```

```bash
paru -S xray ags-hyprpanel-git aylurs-gtk-shell-git bluetui kanata tofi zen-browser-bin lazydocker lazygit
```

```bash
sudo pacman -Syu docker docker-compose go rust nodejs npm pnpm rust
```

---

## Подготовка к установке

### 1. Загрузка с USB и базовая настройка

```bash
# Проверяем режим загрузки (должен быть UEFI)
ls /sys/firmware/efi/efivars

# Подключаемся к интернету (если WiFi)
iwctl
# В iwctl:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "имя_сети"
exit

# Проверяем соединение
ping google.com

# Синхронизируем время
timedatectl set-ntp true
```

### 2. Разметка дисков

```bash
# Смотрим доступные диски
lsblk
fdisk -l

# Запускаем cfdisk для разметки (предполагаем диск /dev/nvme0n1)
cfdisk /dev/nvme0n1
```

**Рекомендуемая схема разделов:**

- EFI System: 512MB (тип: EFI System)
- Root: остальное место (тип: Linux filesystem)

### 3. Создание файловых систем

```bash
# Форматируем EFI раздел
mkfs.fat -F32 /dev/nvme0n1p1

# Создаем btrfs файловую систему
mkfs.btrfs -L arch /dev/nvme0n1p2

# Монтируем root для создания subvolumes
mount /dev/nvme0n1p2 /mnt

# Создаем subvolumes (идиоматичная структура для snapper)
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache
btrfs subvolume create /mnt/@snapshots

# Размонтируем
umount /mnt

```

### 4. Монтирование с правильными опциями

```bash
# Монтируем root subvolume с оптимальными опциями для SSD
mount -o noatime,compress=zstd:3,ssd,subvol=@ /dev/nvme0n1p2 /mnt

# Создаем директории
mkdir -p /mnt/{home,var/log,var/cache,boot,.snapshots}

# Монтируем остальные subvolumes
mount -o noatime,compress=zstd:3,ssd,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,compress=zstd:3,ssd,subvol=@var_log /dev/nvme0n1p2 /mnt/var/log
mount -o noatime,compress=zstd:3,ssd,subvol=@var_cache /dev/nvme0n1p2 /mnt/var/cache
mount -o noatime,compress=zstd:3,ssd,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots

# Монтируем EFI раздел
mount /dev/nvme0n1p1 /mnt/boot
```

## Установка базовой системы

### 5. Установка основных пакетов

```bash
# Обновляем ключи pacman
pacman -Sy archlinux-keyring

# Устанавливаем базовую систему с необходимыми пакетами
pacstrap /mnt base base-devel linux
    linux-firmware linux-headers \\
    btrfs-progs snapper snap-pac \\
    amd-ucode \\
    networkmanager \\
    grub efibootmgr \\
    vim nano \\
    git curl wget \\
    btop neofetch \\
    mesa vulkan-radeon 
    libva-mesa-driver mesa-vdpau \\
    xf86-video-amdgpu\\
    make cmake
```

### 6. Настройка системы

```bash
# Генерируем fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Входим в chroot
arch-chroot /mnt
```

### 7. Базовая конфигурация в chroot

```bash
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
```

```bash
hwclock --systoh
```

```bash
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen
```

```bash
# Настраиваем hostname (заменить на свое имя)
echo "[HOSTNAME]" > /etc/hostname

vim /etc/hosts

# В hosts добавить имя хоста
127.0.0.1   localhost
::1         localhost
127.0.1.1   **[HOSTNAME]**.localdomain **[HOSTNAME]**
```

```bash
passwd
```

### 8. Настройка bootloader

```bash
# Устанавливаем GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Редактируем конфиг GRUB для btrfs
vim /etc/default/grub
```

**В файле /etc/default/grub найди и измени:**

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash rootflags=subvol=@"
```

```bash
# Генерируем конфиг GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

## 11. Создание пользователя

```bash
# Создаем пользователя (замени username на свое имя)
useradd -m -G wheel,audio,video,optical,storage -s /bin/bash **[**USERNAME**]**

# Устанавливаем пароль
passwd [USERNAME]
```

```bash
# Настраиваем sudo
EDITOR=vim visudo

# В файле раскоментируем строку:
%wheel ALL=(ALL:ALL) ALL
```

```bash
# Включим NetworkMangaer чтобы потом не забыть
systemctl enable NetworkManager
```

## Финальные настройки

### 12. Обновление initramfs

```bash
# Добавляем btrfs в initramfs
vim /etc/mkinitcpio.conf
```

**В MODULES добавить:**

```
MODULES=(btrfs amdgpu)
```

```bash
# Пересобираем initramfs
mkinitcpio -P
```

### 13. Завершение установки

```bash
# Выходим из chroot
exit

# Размонтируем файловые системы
umount -R /mnt

# Перезагружаемся
reboot
```

## После первой загрузки

### 14. Конфигурация snapper

```bash
# Удаляем дефолтную директорию .snapshots (она уже примонтирована как subvolume)
umount /.snapshots
rmdir /.snapshots

# Создаем конфиг snapper для root
snapper -c root create-config /

# Удаляем созданный snapper'ом subvolume и восстанавливаем наш
mkdir /.snapshots
mount -o noatime,compress=zstd:3,ssd,subvol=@snapshots /dev/nvme0n1p2 /.snapshots

# Настраиваем автоматическую очистку снапшотов
vim /etc/snapper/configs/root
```

**В файле /etc/snapper/configs/root (менять через sudo vim) изменить:**

```
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
```

### 10. Автоматизация снапшотов

```bash
# Включаем сервисы snapper
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
```

### 14. Проверка и финальная настройка

```bash
# Подключаемся к WiFi
nmcli device wifi connect "имя_сети" password "пароль"

# Обновляем систему
sudo pacman -Syu

# Проверяем snapper
sudo snapper -c root list

# Создаем первый снапшот
sudo snapper -c root create --description "Fresh install"

# Проверяем драйверы AMD
lspci -k | grep -EA3 'VGA|3D|Display'
glxinfo | grep "OpenGL renderer"
```

### 15. Полезные команды для работы со снапшотами

```bash
# Создать снапшот перед важными изменениями
sudo snapper -c root create --description "Before update"

# Посмотреть список снапшотов
sudo snapper -c root list

# Сравнить изменения между снапшотами
sudo snapper -c root status 1..2

# Откатиться к снапшоту (ОСТОРОЖНО!)
sudo snapper -c root undochange 1..2
```

### 16. Геним новый ssh ключ для github и добавляем его туда

```bash
# Геним ключ
ssh-keygen -t ed25519 -C "your_email@example.com"
```

```bash
# Настраиваем пользователя git
git config --global user.name [name]
git config --global user.email [email]
```

```bash
# Выводим и забираем ключ
cat ~/.ssh/ed25519.pub
```

[https://github.com/settings/keys](https://github.com/settings/keys)

---

### **16. Устанавливаем дотфайлы и конфиги. Линкуем через stow.**

```bash
cd ~
git clone git@github.com:rx3lixir/dotfiles.git
```

```bash
cd dotfiles

# Линкуем все конфиги
stow */
```

---

### Настройка под себя.

```bash
# Устанавливаем kanata (Если еще не установлена) 
paru -S kanata xray
```

Для xray нужен config.json.

```bash
# Старт при запуске
systemctl --user enable kanata
systemctl --user enable xray

# Старт прямо сейчас
systemctl --user enable kanata
systemctl --user enable xray
```

### Установка и траблшутинг kanata

1. Создать группу uinput (если её нет)
    
    ```bash
    # Проверим наличие группы unput
    grep uinput /etc/group
    
    # Если группы нет - создаем
    sudo groupadd uinput
    sudo usermod -a -G uinput $USER
    ```
    
2. Добавить пользователя в необходимые группы
    
    ```bash
    sudo usermod -a -G input $USER
    sudo usermod -a -G uinput $USER
    ```
    
3. Настроить udev правила для uinput
    
    ```bash
    # Создаем файл правил для uinput
    sudo vim /etc/udev/rules.d/99-uinput.rules
    
    # Добавляем туда правило
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    ```
    
4. Применяем изменения
    
    ```bash
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    sudo modprobe -r uinput
    sudo modprobe uinput
    ```
    
    После этого перезагрузиться и проверить группы пользователя
    
    ```bash
    groups
    ```
    
    Должны быть группы `input` и `uinput`.
    

---

### Настройка xray c systemd

Добавить из конфига файл для systemd и кинуть конфиг для xray по пути `~/.config/xray/[name].json` 

```bash
# Перезагружаем конфиги пользователя
systemctl --user daemon-reload

# Включаем автозапуск при логине
systemctl --user enable xray

# Запускаем сейчас
systemctl --user start
```