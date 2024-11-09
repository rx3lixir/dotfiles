#!/bin/bash

# Проверка, установлен ли paru
if ! command -v paru &> /dev/null; then
  echo "Paru не установлен. Начинаем установку..."

  # Установка зависимостей
  sudo pacman -Sy --needed --noconfirm base-devel git

  # Клонирование репозитория paru
  git clone https://aur.archlinux.org/paru.git /tmp/paru

  # Переход в каталог и установка paru
  cd /tmp/paru || exit
  makepkg -si --noconfirm

  # Очистка временных файлов
  cd ~ || exit
  rm -rf /tmp/paru

  echo "Paru успешно установлен!"
else
  echo "Paru уже установлен."
fi

