#!/bin/sh
set -e

FIREFOX_DIR="$HOME/.mozilla/firefox"
USERJS="$HOME/.mozilla/firefox/user.js"

if [ ! -f "$USERJS" ]; then
    echo "No $USERJS found"
    exit 1
fi

for PROFILE_DIR in "$FIREFOX_DIR"/*.default* "$FIREFOX_DIR"/*.Default*; do
    if [ -d "$PROFILE_DIR" ]; then
        ln -sf "$USERJS" "$PROFILE_DIR/user.js"
        echo "Linked user.js into: $PROFILE_DIR"
    fi
done

