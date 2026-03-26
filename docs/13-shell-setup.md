# Shell Setup: Fish + Starship + Atuin

## What's configured

`modules/features/shell.nix` sets up the interactive shell environment:

| Tool | Purpose |
|---|---|
| **Fish** | Default login shell — modern, user-friendly, with autosuggestions and syntax highlighting |
| **Starship** | Cross-shell prompt — shows git branch, nix shell status, command duration |
| **Atuin** | Shell history — replaces default history with searchable, synced history database |
| **bat** | `cat` replacement with syntax highlighting (themed by Catppuccin) |
| **fzf** | Fuzzy finder for files and history (themed by Catppuccin) |
| **zoxide** | `cd` replacement that learns your most-used directories (`z` command) |

## Default aliases

```
ll  → ls -la
la  → ls -a
gs  → git status
gc  → git commit
gp  → git push
gl  → git log --oneline
rebuild → just switch
```

## How it's structured

- **NixOS level**: `programs.fish.enable = true` (adds Fish to /etc/shells) +
  sets Fish as the user's default shell
- **Home Manager level**: Fish config, Starship, Atuin, bat, fzf, zoxide are
  all configured via HM `programs.*` options

## Catppuccin integration

When `features.catppuccin.enable = true`, the catppuccin HM module auto-themes
Fish, Starship, bat, and fzf. No manual color config needed for these tools.

## If Fish breaks

Fish is set as the login shell. If something goes wrong:

```bash
# From a TTY or recovery shell:
chsh -s /bin/bash max
```

Or boot a previous NixOS generation from the boot menu.

## Atuin

Atuin replaces Ctrl+R history search. It stores history in a local SQLite
database. Sync is disabled by default (`auto_sync = false`). To enable:

```nix
programs.atuin.settings.auto_sync = true;
```
