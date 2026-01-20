#!/bin/sh
set -eu

echo "🔐 Setting up GitHub SSH access..."

# -----------------------
# 1) Install gh if needed
# -----------------------
if ! command -v gh >/dev/null 2>&1; then
  echo "Installing GitHub CLI..."
  if command -v brew >/dev/null 2>&1; then
    brew install gh
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y gh
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y gh
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm gh
  else
    echo "No supported package manager found for gh."
    exit 1
  fi
fi

# -----------------------
# 2) Login & setup SSH
# -----------------------
if ! gh auth status >/dev/null 2>&1; then
  gh auth login -p ssh -h GitHub.com -w
fi

# -----------------------
# 3) Switch chezmoi repo to SSH
# -----------------------
cd "$CHEZMOI_SOURCE_DIR"

ORIGIN_URL="$(git config --get remote.origin.url)"

if echo "$ORIGIN_URL" | grep -q '^https://github.com/'; then
  SSH_URL="$(echo "$ORIGIN_URL" | sed -E 's#https://github.com/(.*)#git@github.com:\1#')"
  git remote set-url origin "$SSH_URL"
  echo "Switched origin to SSH:"
  echo "  $SSH_URL"
else
  echo "Origin already uses SSH."
fi

