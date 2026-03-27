# NixOS Config Overview

This configuration uses a layered stack of tools that each solve one problem:

| Tool | What it does |
|---|---|
| `flake-parts` | Splits flake outputs into composable modules |
| `import-tree` | Auto-loads every `.nix` file under `modules/` |
| `wrapper-modules` | Wraps programs (niri, noctalia) with typed settings instead of raw config |
| `sops-nix` | Decrypts secrets from git-committed YAML files at login (Home Manager level) |
| `catppuccin/nix` | System-wide Catppuccin Mocha Mauve theming (cursors, Qt, CLI tools, alacritty) |

## File Map

```
flake.nix                          <- entry point, wires inputs together
justfile                           <- task runner (just switch, just update, just gc, etc.)
modules/
  parts.nix                        <- declares supported systems
  hosts/
    my-machine/
      default.nix                  <- creates the nixosConfiguration output
      configuration.nix            <- the actual machine config (imports, enable flags, boot, networking)
      hardware.nix                 <- auto-generated hardware scan (filesystems, kernel modules)
  features/
    variables.nix                  <- centralized variables (username, email, monitor, locale, font, theme, etc.)
    niri.nix                       <- niri compositor + keybinds + xdg portal, built via wrapper-modules
    noctalia.nix                   <- noctalia-shell bar, built via wrapper-modules (Nix attrset config)
    alacritty.nix                  <- alacritty terminal via Home Manager + catppuccin auto-theming
    git.nix                        <- git via Home Manager with centralized variables
    vim.nix                        <- vim via Home Manager with catppuccin plugin
    home.nix                       <- Home Manager config + HM-level SOPS secrets + MCP servers
    shell.nix                      <- Fish shell + Starship prompt + Atuin history + bat/fzf/zoxide
    catppuccin.nix                 <- Catppuccin Mocha Mauve theming (NixOS + Home Manager)
    nvidia.nix                     <- NVIDIA driver feature toggle (videoDrivers + hardware.nvidia)
    zram.nix                       <- Zram compressed swap
    nh.nix                         <- nh Nix helper CLI
    overlays.nix                   <- claude-code and antigravity overlays
    thunar.nix                     <- Thunar file manager + gvfs + tumbler
    browsers.nix                   <- Firefox + Google Chrome
    dev-tools.nix                  <- codex, nodejs, vscode, gh, jq, ripgrep, tree, just
    media.nix                      <- loupe, zathura + image/PDF mime associations
    utilities.nix                  <- anki, nvd, pfetch-rs, bubblewrap
    audio.nix                      <- PipeWire audio stack + sox
    greetd.nix                     <- greetd display manager with tuigreet
    bluetooth.nix                  <- Bluetooth support
    printing.nix                   <- Printing support
```

## How the pieces connect

```
flake.nix
  +-- import-tree loads ALL files in modules/
       +-- each file is a flake-parts module
            |-- parts.nix          -> sets config.systems
            |-- default.nix        -> adds flake.nixosConfigurations.myMachine
            |-- configuration.nix  -> adds flake.nixosModules.myMachineConfiguration
            |-- hardware.nix       -> adds flake.nixosModules.myMachineHardware
            |-- variables.nix      -> adds flake.nixosModules.variables (config.my.variables.*)
            |-- niri.nix           -> adds flake.nixosModules.niri + perSystem.packages.myNiri
            |-- noctalia.nix       -> adds perSystem.packages.myNoctalia
            |-- alacritty.nix      -> adds flake.nixosModules.alacritty (HM programs.alacritty)
            |-- git.nix            -> adds flake.nixosModules.git (HM programs.git)
            |-- vim.nix            -> adds flake.nixosModules.vim (HM programs.vim)
            |-- home.nix           -> adds flake.nixosModules.homeManager (includes HM SOPS)
            |-- shell.nix          -> adds flake.nixosModules.shell (Fish + Starship + Atuin)
            |-- catppuccin.nix     -> adds flake.nixosModules.catppuccin (system-wide theming)
            |-- nvidia.nix         -> adds flake.nixosModules.nvidia
            |-- zram.nix           -> adds flake.nixosModules.zram
            |-- nh.nix             -> adds flake.nixosModules.nh
            |-- overlays.nix       -> adds flake.nixosModules.overlays
            |-- thunar.nix         -> adds flake.nixosModules.thunar
            |-- browsers.nix       -> adds flake.nixosModules.browsers
            |-- dev-tools.nix      -> adds flake.nixosModules.devTools
            |-- media.nix          -> adds flake.nixosModules.media
            |-- utilities.nix      -> adds flake.nixosModules.utilities
            |-- audio.nix          -> adds flake.nixosModules.audio
            |-- greetd.nix         -> adds flake.nixosModules.greetd
            |-- bluetooth.nix      -> adds flake.nixosModules.bluetooth
            +-- printing.nix       -> adds flake.nixosModules.printing
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
