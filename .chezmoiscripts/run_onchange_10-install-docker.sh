#!/bin/sh

set -eu
echo "Installing Docker..."
if command -v docker >/dev/null 2>&1; then
  echo "Docker is already installed."
  exit 0
fi
# Prefer package managers when available
if command -v brew >/dev/null 2>&1; then
  brew install --cask docker || FALLBACK=1
elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || FALLBACK=1
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y dnf-plugins-core
  if sudo dnf config-manager --help 2>&1 | grep -q '\-\-add-repo'; then
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  else
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  fi
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker || FALLBACK=1
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Sy --noconfirm docker
  sudo systemctl enable --now docker || FALLBACK=1
elif command -v apk >/dev/null 2>&1; then
  sudo apk add docker
  sudo rc-update add docker default
  sudo service docker start || FALLBACK=1
else
  FALLBACK=1
fi

if [ "${FALLBACK:-0}" = "1" ]; then
  echo "Warning: No supported package manager found or installation failed. Please install Docker manually: https://docs.docker.com/engine/install/"
  exit 1
fi

echo "Docker installation complete."
