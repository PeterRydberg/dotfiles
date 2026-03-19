#!/bin/sh
set -eu

echo "🔐 Setting up GitHub SSH access (Bitwarden + PAT)..."

SSH_KEY="$HOME/.ssh/id_ed25519"
API_URL="https://api.github.com/user/keys"

# -----------------------
# Dependencies
# -----------------------
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

for cmd in bw jq curl ssh-keygen; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Installing missing dependency: $cmd"
    install_pkg "$cmd"
  fi
done

# -----------------------
# Bitwarden login / unlock
# -----------------------
BW_STATUS="$(bw status | jq -r '.status')"

case "$BW_STATUS" in
  unauthenticated)
    echo "🔐 Bitwarden not logged in. Starting login..."
    bw login
    ;;
  locked)
    echo "🔓 Unlocking Bitwarden..."
    ;;
  unlocked)
    # already unlocked
    ;;
  *)
    echo "Unknown Bitwarden status: $BW_STATUS"
    exit 1
    ;;
esac

# Ensure unlocked and capture session
export BW_SESSION="$(bw unlock --raw)"

# -----------------------
# Fetch secrets
# -----------------------
GITHUB_ITEM="github.com"
GITHUB_PAT_FIELD="github_pat"

ITEM_JSON="$(bw get item "$GITHUB_ITEM")"

GITHUB_PAT="$(echo "$ITEM_JSON" | jq -r \
  --arg field "$GITHUB_PAT_FIELD" \
  '.fields[] | select(.name == $field) | .value')"

GITHUB_EMAIL="$(echo "$ITEM_JSON" | jq -r '.login.username')"

if [ -z "$GITHUB_PAT" ] || [ "$GITHUB_PAT" = "null" ]; then
  echo "GitHub PAT not found in Bitwarden item field: $GITHUB_PAT_FIELD"
  exit 1
fi

if [ -z "$GITHUB_EMAIL" ] || [ "$GITHUB_EMAIL" = "null" ]; then
  echo "GitHub email not found in Bitwarden item username."
  exit 1
fi

# -----------------------
# Generate SSH key if needed
# -----------------------
if [ ! -f "$SSH_KEY" ]; then
  echo "🔑 Generating SSH key..."
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$SSH_KEY"
else
  echo "SSH key already exists."
fi

PUB_KEY="$(cat "$SSH_KEY.pub")"

# -----------------------
# Check if key already exists on GitHub
# -----------------------
if curl -s \
  -H "Authorization: token $GITHUB_PAT" \
  "$API_URL" \
  | jq -e --arg key "$PUB_KEY" '.[] | select(.key == $key)' >/dev/null; then
  echo "SSH key already registered with GitHub."
else
  # -----------------------
  # Prompt for GitHub SSH key title
  # -----------------------
  if command -v hostname >/dev/null 2>&1; then
    DEFAULT_TITLE="$(hostname)"
  elif command -v uname >/dev/null 2>&1; then
    DEFAULT_TITLE="$(uname -n)"
  else
    DEFAULT_TITLE="github-ssh-key"
  fi
  printf "Enter a name for this SSH key on GitHub [%s]: " "$DEFAULT_TITLE"
  read -r KEY_TITLE
  if [ -z "$KEY_TITLE" ]; then
    KEY_TITLE="$DEFAULT_TITLE"
  fi

  echo "📤 Uploading SSH key to GitHub..."
  curl -s -X POST \
    -H "Authorization: token $GITHUB_PAT" \
    -H "Accept: application/vnd.github+json" \
    "$API_URL" \
    -d "$(jq -n \
        --arg title "$KEY_TITLE" \
        --arg key "$PUB_KEY" \
        '{title: $title, key: $key}')" >/dev/null
  echo "SSH key uploaded."
fi

# -----------------------
# Switch chezmoi repo to SSH
# -----------------------
cd "$CHEZMOI_SOURCE_DIR"

ORIGIN_URL="$(git config --get remote.origin.url || true)"

if echo "$ORIGIN_URL" | grep -q '^https://github.com/'; then
  SSH_URL="$(echo "$ORIGIN_URL" | sed -E 's#https://github.com/(.*)#git@github.com:\1#')"
  git remote set-url origin "$SSH_URL"
  echo "🔁 Switched origin to SSH:"
  echo "   $SSH_URL"
else
  echo "Origin already uses SSH."
fi

echo "✅ GitHub SSH setup complete."

