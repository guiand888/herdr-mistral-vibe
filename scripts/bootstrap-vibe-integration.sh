#!/bin/sh
# Bootstrap the companion herdr-vibe Mistral Vibe plugin.
#
# Runs from the plugin's [[startup]] hook on each Herdr server start
# (Herdr 0.7.5+; older versions ignore the section). Idempotent: clones
# the plugin only when missing and re-runs its installer, so hook and
# script updates flow through on each server start.
#
# Opt out:  touch "$(herdr plugin config-dir herdr-vibe)/disable-vibe-integration-bootstrap"
# and run ~/.vibe/plugins/herdr-vibe/install.sh uninstall
set -u

VIBE_PLUGIN_DIR="${VIBE_HOME:-$HOME/.vibe}/plugins/herdr-vibe"
VIBE_PLUGIN_REPO="https://github.com/guiand888/herdr-vibe.git"
OPT_OUT="${HERDR_PLUGIN_CONFIG_DIR:-}/disable-vibe-integration-bootstrap"

log() { echo "herdr-vibe: $*"; }

if [ -n "$OPT_OUT" ] && [ -f "$OPT_OUT" ]; then
  log "opt-out marker present ($OPT_OUT); leaving the Vibe integration alone"
  exit 0
fi

command -v vibe >/dev/null 2>&1 || { log "vibe is not on PATH; nothing to integrate"; exit 0; }
command -v git >/dev/null 2>&1 || { log "git is not on PATH; run the installer manually"; exit 1; }

if [ ! -d "$VIBE_PLUGIN_DIR/.git" ]; then
  if ! git clone --quiet "$VIBE_PLUGIN_REPO" "$VIBE_PLUGIN_DIR"; then
    log "clone failed; run manually: git clone $VIBE_PLUGIN_REPO $VIBE_PLUGIN_DIR"
    exit 1
  fi
  log "cloned herdr-vibe to $VIBE_PLUGIN_DIR"
fi

"$VIBE_PLUGIN_DIR/install.sh"
