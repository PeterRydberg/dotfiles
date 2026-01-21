#!/bin/sh
set -eu

echo "🐙 Installing GitHub CLI..."

if command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI already installed."
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

install_pkg gh

echo "✅ GitHub CLI installed."

