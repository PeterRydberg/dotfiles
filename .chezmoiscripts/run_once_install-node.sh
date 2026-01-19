#!/bin/sh
set -eu

echo "Installing Node.js and npm..."

if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo "Node.js and npm are already installed."
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  brew install node

elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y nodejs npm

elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y nodejs npm

elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm nodejs npm

elif command -v apk >/dev/null 2>&1; then
  sudo apk add nodejs npm

else
  echo "No supported package manager found."
  exit 1
fi

echo "Node.js and npm installation complete."
node --version
npm --version

