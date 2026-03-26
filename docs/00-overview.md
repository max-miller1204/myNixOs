# NixOS Config Overview

This configuration uses a layered stack of tools that each solve one problem:

| Tool | What it does |
|---|---|
| `flake-parts` | Splits flake outputs into composable modules |
| `import-tree` | Auto-loads every `.nix` file under `modules/` |
| `wrapper-modules` | Wraps programs (niri, noctalia, alacritty, git, vim) with typed settings instead of raw config |
| `sops-nix` | Decrypts secrets from git-committed YAML files at login (Home Manager level) |
| `catppuccin/nix` | System-wide Catppuccin Mocha Mauve theming (cursors, Qt, CLI tools) |

## File Map

```
flake.nix                          ← entry point, wires inputs together
justfile                           ← task runner (just switch, just update, just gc, etc.)
modules/
  parts.nix                        ← declares supported systems
  hosts/
    my-machine/
      default.nix                  ← creates the nixosConfiguration output
      configuration.nix            ← the actual machine config (imports, packages, etc.)
      hardware.nix                 ← auto-generated hardware scan (filesystems, kernel modules)
  features/
    variables.nix                  ← centralized variables (username, locale, font, theme)
    niri.nix                       ← niri compositor + keybinds, built via wrapper-modules
    noctalia.nix                   ← noctalia-shell bar, built via wrapper-modules (inline Nix config)
    alacritty.nix                  ← alacritty terminal + Catppuccin colors, built via wrapper-modules
    git.nix                        ← git with bundled config, built via wrapper-modules
    vim.nix                        ← vim with bundled vimrc, built via wrapper-modules
    home.nix                       ← Home Manager config + HM-level SOPS secrets + MCP servers
    shell.nix                      ← Fish shell + Starship prompt + Atuin history + bat/fzf/zoxide
    catppuccin.nix                 ← Catppuccin Mocha Mauve theming (NixOS + Home Manager)
    nvidia.nix                     ← NVIDIA driver feature toggle (videoDrivers + hardware.nvidia)
    zram.nix                       ← Zram compressed swap
    nh.nix                         ← nh Nix helper CLI
    overlays.nix                   ← commented-out overlay template for future use
```

## How the pieces connect

```
flake.nix
  └─ import-tree loads ALL files in modules/
       └─ each file is a flake-parts module
            ├─ parts.nix          → sets config.systems
            ├─ default.nix        → adds flake.nixosConfigurations.myMachine
            ├─ configuration.nix  → adds flake.nixosModules.myMachineConfiguration
            ├─ hardware.nix       → adds flake.nixosModules.myMachineHardware
            ├─ variables.nix      → adds flake.nixosModules.variables (config.my.variables.*)
            ├─ niri.nix           → adds flake.nixosModules.niri + perSystem.packages.myNiri
            ├─ noctalia.nix       → adds perSystem.packages.myNoctalia
            ├─ alacritty.nix      → adds flake.nixosModules.alacritty + perSystem.packages.myAlacritty
            ├─ git.nix            → adds flake.nixosModules.git + perSystem.packages.myGit
            ├─ vim.nix            → adds flake.nixosModules.vim + perSystem.packages.myVim
            ├─ home.nix           → adds flake.nixosModules.homeManager (includes HM SOPS)
            ├─ shell.nix          → adds flake.nixosModules.shell (Fish + Starship + Atuin)
            ├─ catppuccin.nix     → adds flake.nixosModules.catppuccin (system-wide theming)
            ├─ nvidia.nix         → adds flake.nixosModules.nvidia
            ├─ zram.nix           → adds flake.nixosModules.zram
            ├─ nh.nix             → adds flake.nixosModules.nh
            └─ overlays.nix       → placeholder (commented out)
```

Each doc in this folder explains one concept in depth. Read them in order:

1. `01-flake-parts.md` — what flake-parts is and what a "flake-parts module" looks like
2. `02-import-tree.md` — how every file in modules/ gets auto-loaded
3. `03-self-and-self-prime.md` — what `self`, `self'`, and `inputs` are
4. `04-nixos-modules.md` — how `flake.nixosModules` and `nixosSystem` fit together
5. `05-per-system.md` — what `perSystem` does and why it exists
6. `06-wrapper-modules.md` — how wrapper-modules builds typed program configs
7. `07-adding-a-machine.md` — recipe: add a second machine
8. `08-adding-a-feature.md` — recipe: add a new feature module
9. `09-claude-code-mcp.md` — recipe: add an MCP server to Claude Code
10. `09-context7-secrets.md` — recipe: manage secrets with sops-nix (API keys, tokens, etc.)
11. `10-vimjoyer-videos.md` — curated Vimjoyer video reference organized by topic
12. `11-centralized-variables.md` — how `config.my.variables.*` works
13. `12-justfile-commands.md` — quick reference for all `just` commands
14. `13-shell-setup.md` — Fish + Starship + Atuin configuration
15. `14-catppuccin-theming.md` — how Catppuccin theming is applied across the system
