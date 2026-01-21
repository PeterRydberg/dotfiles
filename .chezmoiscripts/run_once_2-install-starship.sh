#!/bin/sh
set -eu

echo "Installing Starship..."

if command -v starship >/dev/null 2>&1; then
  echo "Starship is already installed."
  exit 0
fi

# Prefer package managers when available
if command -v brew >/dev/null 2>&1; then
  brew install starship

elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y starship

elif command -v dnf >/dev/null 2>&1; then
  sudo dnf copr enable atim/starship 
  sudo dnf install -y starship

elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm starship

elif command -v apk >/dev/null 2>&1; then
  sudo apk add starship

else
  echo "No supported package manager found."
  echo "Falling back to official Starship install script..."

  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

echo "Starship installation complete."

