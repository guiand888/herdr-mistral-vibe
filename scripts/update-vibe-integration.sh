#!/bin/sh
# Update the cloned herdr-vibe Mistral Vibe plugin and refresh its hooks.
# Wired to the plugin's update-vibe-integration action.
set -eu

VIBE_PLUGIN_DIR="${VIBE_HOME:-$HOME/.vibe}/plugins/herdr-vibe"

if [ ! -d "$VIBE_PLUGIN_DIR/.git" ]; then
  echo "herdr-vibe is not installed at $VIBE_PLUGIN_DIR; it is cloned on the next Herdr start" >&2
  exit 1
fi

git -C "$VIBE_PLUGIN_DIR" pull --ff-only
"$VIBE_PLUGIN_DIR/install.sh"
