#!/bin/sh
set -eu

echo "Configuring Firefox user.js..."

FIREFOX_DIR="$HOME/.mozilla/firefox"
USERJS="$FIREFOX_DIR/user.js"

# Ensure Firefox exists
if ! command -v firefox >/dev/null 2>&1; then
  echo "Firefox is not installed. Skipping user.js setup."
  exit 0
fi

# Ensure Firefox directory exists
mkdir -p "$FIREFOX_DIR"

# Ensure at least one Firefox profile exists (headless, no UI)
if ! find "$FIREFOX_DIR" -maxdepth 1 -type d -name "*.default*" -print -quit | grep -q .; then
  echo "No Firefox profile found. Creating default profile..."
  firefox -headless -CreateProfile default >/dev/null 2>&1 || true
fi

# Ensure user.js source exists
if [ ! -f "$USERJS" ]; then
  echo "No $USERJS found. Skipping user.js linking."
  exit 0
fi

# Link user.js into all default profiles
for PROFILE_DIR in "$FIREFOX_DIR"/*.default* "$FIREFOX_DIR"/*.Default*; do
  if [ -d "$PROFILE_DIR" ]; then
    ln -sf "$USERJS" "$PROFILE_DIR/user.js"
    echo "Linked user.js into: $PROFILE_DIR"
  fi
done

echo "Firefox user.js configuration complete."

