#!/bin/sh
set -eu

echo "Installing Zsh..."

if command -v zsh >/dev/null 2>&1; then
  echo "Zsh is already installed."
  exit 0
fi

if command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y zsh

elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y zsh

elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm zsh

elif command -v brew >/dev/null 2>&1; then
  brew install zsh

elif command -v apk >/dev/null 2>&1; then
  sudo apk add zsh

else
  echo "No supported package manager found. Install Zsh manually."
  exit 1
fi

echo "Zsh installation complete."

if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "Setting Zsh as default shell..."
  chsh -s "$(command -v zsh)"
fi


