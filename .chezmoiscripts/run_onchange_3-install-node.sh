#!/bin/sh
set -eu
echo "Installing Node.js LTS via nvm..."

# -----------------------
# Install nvm
# -----------------------
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash
fi

# Load nvm into current shell session
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# -----------------------
# Detect existing Node
# -----------------------
if command -v node >/dev/null 2>&1; then
  NODE_VERSION="$(node -v | sed 's/^v//')"
  NODE_MAJOR="$(echo "$NODE_VERSION" | cut -d. -f1)"
  if [ "$NODE_MAJOR" -ge 20 ]; then
    echo "Node.js $NODE_VERSION already installed."
    exit 0
  else
    echo "Outdated Node.js detected ($NODE_VERSION), upgrading..."
  fi
fi

# -----------------------
# Install Node LTS via nvm
# -----------------------
if command -v nvm >/dev/null 2>&1; then
  nvm install --lts
  nvm use --lts
  nvm alias default "lts/*"
else
  FALLBACK=1
fi

if [ "${FALLBACK:-0}" = "1" ]; then
  echo "Warning: nvm installation failed or could not be loaded. Please install Node.js manually: https://nodejs.org"
  exit 1
fi

echo "Node.js installation complete."
node -v
npm -v
