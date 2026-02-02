# Dotfiles

Personal dotfiles repository that manages configuration files across machines by creating symlinks from this repo to their deployed locations.

## Structure

- `dotfiles.yaml` - Configuration mapping repo files to deployment paths
- `dotfile.py` - CLI tool for managing dotfiles (sync, deploy, status)
- Each directory (zsh/, vim/, kitty/, etc.) contains config files for that tool

## Running dotfile.py

```bash
uv run dotfile.py <command> [options]
```

Commands:
- `deploy -g <group> --copy-mode soft` - Create symlinks from repo to deploy locations
- `sync -g <group>` - Copy deployed files back to repo
- `status -g <group>` - Check if deployed files match repo
- `add -g <group> <file>` - Add a new file to track

Copy modes:
- `soft` - Create symlinks (preferred for deployment)
- `hard` - Create hard links
- `copy` - Copy files

## Workflow

1. Edit files in the repo
2. Run `uv run dotfile.py deploy -g <group> --copy-mode soft` to deploy
3. Or edit deployed files, then `uv run dotfile.py sync -g <group>` to sync back

## Groups

Groups are defined in `dotfiles.yaml` under `files:`. Examples: zsh, vim, kitty, git, vscode, cursor, tmux.
