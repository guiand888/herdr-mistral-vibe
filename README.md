# herdr-vibe

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg)](https://github.com/RichardLitt/standard-readme)

> Herdr plugin that starts Mistral Vibe sessions in Herdr panes.

Companion to [herdr-vibe](https://github.com/guiand888/herdr-vibe), the Mistral Vibe plugin that reports agent state and resume commands. The pair makes Mistral Vibe feature-complete in Herdr: this plugin opens panes and keybindings, that one supplies sidebar state, notifications, and session restore.

Herdr cannot register unknown agent kinds, so `herdr agent start --kind vibe` is unavailable for Mistral Vibe. This plugin provides the same entry point through plugin v1 surfaces: an action that opens a split pane running `vibe`, and a pane entrypoint usable directly.

## Install

Requires Herdr 0.7 or newer and `vibe` on `PATH`.

```bash
herdr plugin install guiand888/herdr-mistral-vibe
```

Or, from a local checkout:

```bash
herdr plugin link /path/to/herdr-vibe
```

## Startup behavior

The plugin makes sure the companion Vibe integration from [`herdr-vibe`](https://github.com/guiand888/herdr-vibe) is in place: it clones that repository to `~/.vibe/plugins/herdr-vibe` when missing and runs its installer, which registers the state-reporting hooks. It requires `vibe`, `git`, and `python3` on `PATH`, skips cleanly when they are absent, and is idempotent.

The `[[startup]]` hook runs after every Herdr server start (boot, update, restart, or live handoff — Herdr 0.7.5 or newer; older versions ignore it), so hook updates flow through on each restart. It does **not** run when a plugin is installed or linked into an already-running server. To bootstrap or update without waiting for the next restart:

```bash
herdr plugin action invoke update-vibe-integration --plugin herdr-vibe
```

To remove the integration permanently instead of letting it come back on the next start:

```bash
touch "$(herdr plugin config-dir herdr-vibe)/disable-vibe-integration-bootstrap"
~/.vibe/plugins/herdr-vibe/install.sh uninstall
```

## Usage

Start a Mistral Vibe pane:

```bash
herdr plugin action invoke start --plugin herdr-vibe
```

Or bind it to a key in `config.toml`:

```toml
[[keys.command]]
key = "prefix+v"
type = "plugin_action"
command = "herdr-vibe.start"
```

The action opens a split pane running `vibe` (entrypoint `vibe`, also openable with `herdr plugin pane open --plugin herdr-vibe --entrypoint vibe`). Sidebar state, notifications, and session restore inside the pane come from the companion plugin above.

## Maintainers

Guillaume Andre \<mail@guillaumea.fr\>

## Contributing

Issues and pull requests welcome.

## License

AGPL-3.0-only © 2026 Guillaume Andre
