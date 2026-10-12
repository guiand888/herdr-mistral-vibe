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
