#!/bin/sh
# Install or update the cloned herdr-vibe Mistral Vibe plugin.
#
# Wired to the plugin's update-vibe-integration action. Bridges the gap
# between installing this plugin into an already-running server and the
# next server start: it bootstraps the companion plugin when missing
# (same as the startup hook) or updates and reinstalls it when present.
set -eu

SELF_DIR=$(CDPATH='' cd -- "${0%/*}" && pwd -P)
VIBE_PLUGIN_DIR="${VIBE_HOME:-$HOME/.vibe}/plugins/herdr-vibe"

command -v git >/dev/null 2>&1 || { echo "herdr-vibe: git is not on PATH" >&2; exit 1; }

if [ ! -d "$VIBE_PLUGIN_DIR/.git" ]; then
  exec sh "$SELF_DIR/bootstrap-vibe-integration.sh"
fi

git -C "$VIBE_PLUGIN_DIR" pull --ff-only
"$VIBE_PLUGIN_DIR/install.sh"
