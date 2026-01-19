#!/bin/sh
set -eu

echo "Installing Firefox..."

if command -v firefox >/dev/null 2>&1; then
  echo "Firefox already installed."
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  brew install --cask firefox

elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y firefox

elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y firefox

elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm firefox

elif command -v apk >/dev/null 2>&1; then
  sudo apk add firefox

else
  echo "No supported package manager found."
  exit 1
fi

echo "Firefox installation complete."

