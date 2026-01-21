#!/bin/sh
set -eu

echo "🟢 Installing latest Node.js LTS..."

# -----------------------
# Detect existing Node
# -----------------------
if command -v node >/dev/null 2>&1; then
  NODE_VERSION="$(node -v | sed 's/^v//')"
  NODE_MAJOR="$(echo "$NODE_VERSION" | cut -d. -f1)"

  # Require Node >= 20 for modern ESM compatibility
  if [ "$NODE_MAJOR" -ge 20 ]; then
    echo "Node.js $NODE_VERSION already installed."
    exit 0
  else
    echo "Outdated Node.js detected ($NODE_VERSION), upgrading..."
  fi
fi

# -----------------------
# Install via NodeSource
# -----------------------
install_nodesource() {
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
}

if command -v apt >/dev/null 2>&1; then
  install_nodesource

elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y nodejs

elif command -v zypper >/dev/null 2>&1; then
  sudo zypper install -y nodejs

elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm nodejs npm

else
  echo "No supported package manager found for Node.js."
  exit 1
fi

echo "✅ Node.js installed:"
node -v
npm -v

