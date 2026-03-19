#!/bin/sh
set -eu
echo "Installing fzf..."

# -----------------------
# Install fzf
# -----------------------
if [ ! -d "$HOME/.fzf" ]; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-update-rc
else
  echo "fzf already installed."
fi

echo "fzf installation complete."
