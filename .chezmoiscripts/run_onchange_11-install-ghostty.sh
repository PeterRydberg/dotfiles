#!/bin/sh
set -eu
echo "Installing Ghostty..."

if command -v ghostty >/dev/null 2>&1; then
  echo "Ghostty is already installed."
  exit 0
fi

FALLBACK=0

ensure_snap() {
  if command -v snap >/dev/null 2>&1; then
    return 0
  fi
  echo "Snap not found. Attempting to install snapd..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y snapd || return 1
    sudo systemctl enable --now snapd.socket || true
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y snapd || return 1
    sudo systemctl enable --now snapd.socket || true
    # Fedora requires a symlink for classic snaps
    sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
  else
    return 1
  fi
}

if [ "$(uname)" = "Darwin" ]; then
  if command -v brew >/dev/null 2>&1; then
    brew install --cask ghostty || FALLBACK=1
  else
    FALLBACK=1
  fi
elif [ "$(uname)" = "Linux" ]; then
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm ghostty || FALLBACK=1
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add ghostty || FALLBACK=1
  elif command -v eopkg >/dev/null 2>&1; then
    sudo eopkg install ghostty || FALLBACK=1
  elif command -v apt >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1; then
    # Neither apt nor dnf have Ghostty in their default repos — use Snap
    if ensure_snap; then
      sudo snap install ghostty --classic || FALLBACK=1
    else
      FALLBACK=1
    fi
  elif command -v snap >/dev/null 2>&1; then
    sudo snap install ghostty --classic || FALLBACK=1
  else
    FALLBACK=1
  fi
else
  FALLBACK=1
fi

if [ "${FALLBACK}" = "1" ]; then
  echo "Warning: Could not install Ghostty automatically."
  echo "Please install it manually: https://ghostty.org/docs/install/binary"
fi

echo "Ghostty installation complete."
