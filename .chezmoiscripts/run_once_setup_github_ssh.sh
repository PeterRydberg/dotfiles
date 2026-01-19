#!/bin/sh
set -eu

echo "🔐 Setting up GitHub SSH + switching repo remote..."

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
    echo "No supported package manager found for gh. Install it manually."
    exit 1
  fi
fi

# -----------------------
# 2) Get email from chezmoi data
# -----------------------
GIT_EMAIL="$(chezmoi data git.email 2>/dev/null || true)"

if [ -z "$GIT_EMAIL" ]; then
  # Prompt fallback
  printf "Enter your email for GitHub SSH key: "
  read -r GIT_EMAIL
fi

if [ -z "$GIT_EMAIL" ]; then
  echo "Email cannot be empty."
  exit 1
fi

# -----------------------
# 3) Create SSH key if missing
# -----------------------
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY" ]; then
  echo "Creating SSH key for $GIT_EMAIL..."
  ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$GIT_EMAIL"
fi

eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# -----------------------
# 4) Prompt for title
# -----------------------
printf "Enter a title for this SSH key (e.g. 'laptop-$(hostname)'): "
read -r KEY_TITLE

if [ -z "$KEY_TITLE" ]; then
  echo "Key title cannot be empty."
  exit 1
fi

# -----------------------
# 5) Login to GitHub
# -----------------------
if ! gh auth status >/dev/null 2>&1; then
  gh auth login
fi

# -----------------------
# 6) Upload SSH key
# -----------------------
PUBKEY="$SSH_KEY.pub"

if gh ssh-key list | grep -q "$KEY_TITLE"; then
  echo "SSH key with this title already exists on GitHub."
else
  gh ssh-key add "$PUBKEY" --title "$KEY_TITLE"
  echo "SSH key uploaded to GitHub!"
fi

# -----------------------
# 7) Switch chezmoi repo to SSH
# -----------------------
CHEZMOI_REPO_DIR="$(chezmoi source-path 2>/dev/null || true)"

if [ -z "$CHEZMOI_REPO_DIR" ]; then
  echo "Could not determine chezmoi source path."
  exit 1
fi

cd "$CHEZMOI_REPO_DIR"

ORIGIN_URL="$(git config --get remote.origin.url || true)"

if [ -z "$ORIGIN_URL" ]; then
  echo "No git remote origin found."
  exit 1
fi

if echo "$ORIGIN_URL" | grep -q '^https://github.com/'; then
  SSH_URL="$(echo "$ORIGIN_URL" | sed -E 's#https://github.com/(.*)#git@github.com:\1#')"
  git remote set-url origin "$SSH_URL"
  echo "Switched remote to SSH: $SSH_URL"
fi

# -----------------------
# 8) Re-apply chezmoi with SSH remote
# -----------------------
chezmoi apply

