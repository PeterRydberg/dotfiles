#!/bin/sh
set -eu
echo "Installing Git..."
if command -v git >/dev/null 2>&1; then
  echo "Git is already installed."
  exit 0
fi
# Prefer package managers when available
if command -v brew >/dev/null 2>&1; then
  brew install git || FALLBACK=1
elif command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y git || FALLBACK=1
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y git || FALLBACK=1
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm git || FALLBACK=1
elif command -v apk >/dev/null 2>&1; then
  sudo apk add git || FALLBACK=1
else
  FALLBACK=1
fi

if [ "${FALLBACK:-0}" = "1" ]; then
  echo "Warning: No supported package manager found or installation failed. Please install Git manually: https://git-scm.com/downloads"
fi
echo "Git installation complete."
