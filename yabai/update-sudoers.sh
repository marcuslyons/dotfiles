#!/bin/bash

# update-sudoers.sh
# Updates the /etc/sudoers.d/yabai file with the current yabai binary hash.
# This is required for the scripting addition to load without a password.

YABAI_PATH=$(which yabai)

if [ -z "$YABAI_PATH" ]; then
    echo "Error: yabai not found in PATH"
    exit 1
fi

YABAI_HASH=$(shasum -a 256 "$YABAI_PATH" | cut -d " " -f 1)
USER_NAME=$(whoami)
SUDOERS_LINE="${USER_NAME} ALL=(root) NOPASSWD: sha256:${YABAI_HASH} ${YABAI_PATH} --load-sa"

echo "Updating /etc/sudoers.d/yabai..."
echo "New hash: ${YABAI_HASH}"

echo "$SUDOERS_LINE" | sudo tee /etc/sudoers.d/yabai > /dev/null

echo "Restarting yabai service to apply changes..."
yabai --restart-service

echo "Scripting addition should now be loaded."
