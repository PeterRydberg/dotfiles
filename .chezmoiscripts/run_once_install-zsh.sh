#!/bin/sh
set -eu

echo "🐚 Installing Zsh..."

# -----------------------
# 1) Install zsh
# -----------------------
if command -v zsh >/dev/null 2>&1; then
  echo "Zsh is already installed."
else
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y zsh

  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh

  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm zsh

  elif command -v apk >/dev/null 2>&1; then
    sudo apk add zsh

  elif command -v brew >/dev/null 2>&1; then
    brew install zsh

  else
    echo "No supported package manager found. Install Zsh manually."
    exit 1
  fi
fi

ZSH_PATH="$(command -v zsh)"

# -----------------------
# 2) Ensure zsh is in /etc/shells
# -----------------------
if ! grep -q "^$ZSH_PATH$" /etc/shells 2>/dev/null; then
  echo "Adding zsh to /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# -----------------------
# 3) Set zsh as default shell
# -----------------------
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7 || true)"

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
  echo "Zsh is already the default shell."
  exit 0
fi

echo "Setting Zsh as default shell..."

# Fedora-specific behavior
if command -v dnf >/dev/null 2>&1; then
  if command -v chsh >/dev/null 2>&1; then
    sudo chsh -s "$ZSH_PATH" "$USER" || true
  elif command -v lchsh >/dev/null 2>&1; then
    sudo lchsh "$USER" "$ZSH_PATH" || true
  else
    echo "Could not find chsh or lchsh on Fedora."
    exit 1
  fi
else
  chsh -s "$ZSH_PATH"
fi

