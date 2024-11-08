#!/bin/bash

# Установка HyprPanel
echo "Клонируем репозиторий HyprPanel..."
if [ ! -d "$HOME/HyprPanel" ]; then
  git clone https://github.com/Jas-SinghFSU/HyprPanel.git $HOME/HyprPanel
else
  echo "HyprPanel уже клонирован. Обновляем репозиторий..."
  git -C $HOME/HyprPanel pull
fi

# Создание символической ссылки для HyprPanel
if [ ! -L "$HOME/.config/ags" ]; then
  echo "Создаем символическую ссылку ~/.config/ags на HyprPanel..."
  ln -s $HOME/HyprPanel $HOME/.config/ags
else
  echo "Символическая ссылка ~/.config/ags уже существует."
fi
