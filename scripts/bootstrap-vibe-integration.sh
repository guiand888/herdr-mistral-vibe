#!/bin/sh
# Bootstrap or update the companion herdr-vibe Mistral Vibe plugin.
#
# Without arguments (the plugin's [[startup]] hook, Herdr 0.7.5+): clone
# https://github.com/guiand888/herdr-vibe to ~/.vibe/plugins/herdr-vibe
# when missing, bring an out-of-range clone back into the supported
# version range, then run its installer. Idempotent, safe on every start.
#
# With --update (the plugin's update-vibe-integration action): also pull
# the latest version when the clone already exists, so bugfixes arrive
# without waiting for a server restart.
#
# Opt out:  touch "$(herdr plugin config-dir herdr-vibe)/disable-vibe-integration-bootstrap"
# and run ~/.vibe/plugins/herdr-vibe/install.sh uninstall
set -u

VIBE_PLUGIN_DIR="${VIBE_HOME:-$HOME/.vibe}/plugins/herdr-vibe"
VIBE_PLUGIN_REPO="https://github.com/guiand888/herdr-vibe.git"
OPT_OUT="${HERDR_PLUGIN_CONFIG_DIR:-}/disable-vibe-integration-bootstrap"
# Compatible range for the cloned plugin. This plugin consumes the
# companion's install.sh interface, hook registration, and report script
# path; bump MIN when this plugin requires newer companion behavior, and
# bump MAX_MAJOR when the companion ships incompatible changes.
VIBE_PLUGIN_MIN_VERSION="1.0.0"
VIBE_PLUGIN_MAX_MAJOR="1"

log() { echo "herdr-vibe: $*"; }

if [ "${1:-}" = "--update" ]; then
  UPDATE=1
else
  UPDATE=0
fi

if [ -n "$OPT_OUT" ] && [ -f "$OPT_OUT" ]; then
  log "opt-out marker present ($OPT_OUT); leaving the Vibe integration alone"
  exit 0
fi

command -v vibe >/dev/null 2>&1 || { log "vibe is not on PATH; nothing to integrate"; exit 0; }
command -v git >/dev/null 2>&1 || { log "git is not on PATH; run the installer manually"; exit 1; }
command -v python3 >/dev/null 2>&1 || { log "python3 is not on PATH; the reporting hooks cannot run"; exit 0; }

if [ ! -d "$VIBE_PLUGIN_DIR/.git" ]; then
  if ! git clone --quiet "$VIBE_PLUGIN_REPO" "$VIBE_PLUGIN_DIR"; then
    log "clone failed; run manually: git clone $VIBE_PLUGIN_REPO $VIBE_PLUGIN_DIR"
    exit 1
  fi
  log "cloned herdr-vibe to $VIBE_PLUGIN_DIR"
elif [ "$UPDATE" = "1" ]; then
  if git -C "$VIBE_PLUGIN_DIR" pull --ff-only origin main >/dev/null 2>&1; then
    log "updated the cloned herdr-vibe plugin"
  else
    log "could not update the clone; continuing with the current version"
  fi
fi

read_plugin_version() {
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' \
    "$VIBE_PLUGIN_DIR/plugin.json" 2>/dev/null
}

version_in_range() {
  python3 -c '
import sys
def key(value):
    parts = []
    for piece in value.split("."):
        if not piece.isdigit():
            sys.exit(2)
        parts.append(int(piece))
    return parts
installed = key(sys.argv[1])
minimum = key(sys.argv[2])
max_major = int(sys.argv[3])
if installed < minimum or installed[0] > max_major:
    sys.exit(1)
' "$1" "$VIBE_PLUGIN_MIN_VERSION" "$VIBE_PLUGIN_MAX_MAJOR"
}

installed="$(read_plugin_version)" || {
  log "cannot read the plugin version from $VIBE_PLUGIN_DIR/plugin.json; run the installer manually"
  exit 1
}

if ! version_in_range "$installed"; then
  # Try to bring an out-of-range clone back onto a supported version.
  git -C "$VIBE_PLUGIN_DIR" pull --ff-only origin main >/dev/null 2>&1 || true
  installed="$(read_plugin_version)" || installed=""
  if [ -z "$installed" ] || ! version_in_range "$installed"; then
    log "the cloned herdr-vibe plugin version is outside the supported range $VIBE_PLUGIN_MIN_VERSION .. $VIBE_PLUGIN_MAX_MAJOR.x; not installing"
    log "update this plugin (herdr plugin update) or pin the clone to a supported version"
    exit 1
  fi
  log "updated the cloned herdr-vibe plugin to $installed"
fi

"$VIBE_PLUGIN_DIR/install.sh"
