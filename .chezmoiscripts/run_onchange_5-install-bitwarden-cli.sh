#!/bin/sh
set -eu

echo "🔐 Installing Bitwarden CLI..."

if command -v bw >/dev/null 2>&1; then
  echo "Bitwarden CLI already installed."
  exit 0
fi

install_pkg() {
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "$@"
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y "$@"
  else
    echo "No supported package manager found."
    exit 1
  fi
}

# Bitwarden CLI is often packaged as "bw"
install_pkg bw || {
  echo "bw not found in repos, installing via npm..."

  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found; Node.js installation failed."
    exit 1
  fi

  sudo npm install -g @bitwarden/cli
}

echo "✅ Bitwarden CLI installed."

