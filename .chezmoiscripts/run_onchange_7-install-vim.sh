#!/bin/sh
set -eu

echo "✏️  Installing Vim..."

# -----------------------
# 1) Install vim
# -----------------------
if command -v vim >/dev/null 2>&1; then
  echo "Vim is already installed."
else
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y vim

  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y vim-enhanced || sudo dnf install -y vim

  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm vim

  elif command -v apk >/dev/null 2>&1; then
    sudo apk add vim

  elif command -v brew >/dev/null 2>&1; then
    brew install vim

  else
    echo "No supported package manager found. Install Vim manually."
    exit 1
  fi
fi

# -----------------------
# 2) Optionally set default editor
# -----------------------
# Only set if EDITOR is unset
if [ -z "${EDITOR:-}" ]; then
  echo "Setting Vim as default editor..."
  {
    echo 'export EDITOR=vim'
    echo 'export VISUAL=vim'
  } >> "$HOME/.profile"
fi

