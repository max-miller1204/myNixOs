# modules/aspects/ — Aspect Modules

Reusable den aspects. Each `.nix` file defines `den.aspects.<name>` with class-keyed blocks. Non-Nix assets (`.kdl`, `.json`, `.sh`, `.png`) are co-located and deployed via `xdg.configFile` or `home.file`.

## STRUCTURE

```
aspects/
├── max.nix              # User aspect aggregator — includes all user-facing aspects
├── shell.nix            # fish, starship, atuin, bat, fzf, zoxide + fish functions (worktrees, tmux layouts, SSH forwarding, utilities) + eza/docker/git/claude aliases
├── git.nix              # Git config + credential helper + histogram diffs, rerere, aliases (sync/co/br/ci/st)
├── vim.nix              # Vim + catppuccin theme (neovim is in dev-tools, LazyVim managed externally)
├── tmux.nix             # Tmux with omarchy-style keybindings (Ctrl-a prefix, prefix-free pane/window nav)
├── alacritty.nix        # Terminal emulator (inactive, replaced by ghostty)
├── ghostty.nix          # Terminal emulator (active, kitty graphics protocol)
├── dev-tools.nix        # neovim, nodejs, gh, jq, ripgrep, eza, fd, lazygit, dust, fastfetch, gum (HM) + vscode (hmLinux)
├── mcp.nix              # MCP servers + sops secrets + activation scripts (117 lines)
├── harnix.nix           # Harnix HM module integration
├── utilities.nix        # nvd, pfetch (HM) + anki, bubblewrap (hmLinux)
├── media.nix            # loupe, zathura + mime associations (hmLinux)
├── browsers.nix         # firefox (NixOS) + chrome (hmLinux)
├── catppuccin.nix       # Catppuccin mocha/mauve theme (NixOS + HM + hmLinux GTK/Qt)
├── nix-settings.nix     # Nix config (os) + GC (nixos/darwin separately)
├── overlays.nix         # Flake overlays + system packages (NixOS only)
├── niri.nix             # Compositor (NixOS) + config.kdl deployment
├── niri/config.kdl      # Niri keybinds/layout — edit directly
├── noctalia.nix         # Status bar (NixOS) + settings.json deployment
├── noctalia/settings.json
├── greetd.nix           # Display manager (NixOS)
├── nvidia.nix           # GPU drivers (NixOS)
├── audio.nix            # PipeWire (NixOS)
├── bluetooth.nix        # Bluetooth (NixOS)
├── printing.nix         # CUPS (NixOS)
├── zram.nix             # Compressed swap (NixOS)
├── thunar.nix           # File manager (NixOS + provides.to-users)
├── fingerprint.nix      # Fingerprint reader (NixOS)
├── flatpak.nix          # Flatpak (NixOS)
├── darwin-base.nix      # Trackpad, keyboard, Touch ID (darwin)
├── homebrew.nix         # Declarative Homebrew casks (darwin)
├── aerospace.nix        # Window manager (hmDarwin)
├── karabiner.nix        # Key remapping (hmDarwin)
├── karabiner/karabiner.json
├── claude/              # Claude Code dotfiles (settings.json, statusline.sh, skills/)
├── opencode/            # OpenCode config (oh-my-opencode.json)
└── wallpaper.png        # Desktop wallpaper asset
```

## WHERE TO LOOK

| Task | File | Class key |
|------|------|-----------|
| Add cross-platform user tool | Existing or new aspect | `homeManager.home.packages` |
| Add Linux-only user tool | Existing or new aspect | `hmLinux.home.packages` |
| Add macOS Homebrew app | `homebrew.nix` | `darwin` (casks list) |
| Add NixOS system service | Existing or new aspect | `nixos` |
| Add darwin system pref | `darwin-base.nix` or new aspect | `darwin` |
| Add cross-platform OS config | Existing or new aspect | `os` |
| Deploy config file to users | In the aspect | `provides.to-users.homeManager` |
| Add MCP server | `mcp.nix` | `homeManager` (add to `mcpServers` attrset) |
| Add overlay/flake package | `overlays.nix` | `nixos` |
| Include aspect for user | `max.nix` → `includes` list | n/a |
| Include aspect for NixOS host | `../hosts/nixos.nix` → `includes` | n/a |
| Include aspect for macOS host | `../hosts/my-macbook.nix` → `includes` | n/a |
| Add shell function | `shell.nix` → `programs.fish.functions` | `homeManager` |
| Add shell alias | `shell.nix` → `programs.fish.shellAliases` | `homeManager` |
| Modify tmux keybindings | `tmux.nix` → `extraConfig` | `homeManager` |
| Modify git settings | `git.nix` → `programs.git.settings` | `homeManager` |

## CONVENTIONS

- Every `.nix` file is `{ self, inputs, ... }: { den.aspects.<name> = { ... }; }` — no `mkEnableOption`.
- Aspect name matches filename: `shell.nix` → `den.aspects.shell`.
- `max.nix` is the sole user aggregator — all user-facing aspects go in its `includes`.
- Host aspects are NOT here — they live in `../hosts/`.
- Non-Nix assets live in subdirectories named after the aspect (e.g., `niri/config.kdl`).
- `mcp.nix` is the most complex file (117 lines) — contains inline shell scripts, sops secrets, activation hooks, and TOML generation.
- Neovim is installed as a package in `dev-tools.nix`. LazyVim manages plugins externally in `~/.config/nvim` (not Nix-managed).

## ANTI-PATTERNS

- Never use `mkIf pkgs.stdenv.isLinux` — use `hmLinux` or `nixos` class key.
- Never use `mkEnableOption` / `mkIf config.*.enable` — den aspects replace this.
- Never put host→user config in a host-level `homeManager` block — use `provides.to-users`.
- Never reference aspect files in `flake.nix` — import-tree auto-discovers them.
