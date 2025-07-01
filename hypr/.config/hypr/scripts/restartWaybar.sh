#!/bin/bash

echo "Перезагружаю waybar..."

# Убиваем все процессы waybar
pkill waybar

# Ждем немного, чтобы процессы точно завершились
sleep 1

# Запускаем waybar заново в фоновом режиме
waybar &

echo "Waybar перезагружен!"
