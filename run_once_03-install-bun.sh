#!/bin/bash

# Проверка, установлен ли bun
if ! command -v bun &> /dev/null; then
  echo "Bun не установлен. Начинаем установку..."

  # Установка bun
  curl -fsSL https://bun.sh/install | bash

  # Добавление bun в PATH для zsh
  if [[ -n "$ZSH_VERSION" ]]; then
    if ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' ~/.zshrc; then
      echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.zshrc
      source ~/.zshrc
    fi
  fi

  # Добавление bun в PATH для bash
  if [[ -n "$BASH_VERSION" ]]; then
    if ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' ~/.bashrc; then
      echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
      source ~/.bashrc
    fi
  fi

  echo "Bun успешно установлен!"
else
  echo "Bun уже установлен."
fi

