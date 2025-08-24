#!/bin/sh
set -e

# Find the default Firefox profile directory from profiles.ini
PROFILE_DIR=$(awk -F= '/^\[Profile[^0-9]*\]/{p=0} /Default=1/{p=1} p && /^Path=/{print $2}' ~/.mozilla/firefox/profiles.ini)

# Expand tilde if present
PROFILE_DIR="${PROFILE_DIR/#\~/$HOME}"

# Bail if nothing found
if [ -z "$PROFILE_DIR" ]; then
    echo "Could not find default Firefox profile."
    exit 1
fi

# Ensure target exists
mkdir -p "$HOME/.mozilla/firefox/$PROFILE_DIR"

# Symlink user.js from chezmoi-managed config
ln -sf "$HOME/.config/firefox/user.js" "$HOME/.mozilla/firefox/$PROFILE_DIR/user.js"

echo "Linked user.js into Firefox profile: $PROFILE_DIR"

