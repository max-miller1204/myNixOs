# Den Configuration Guide

This repo uses [den](https://github.com/vic/den), an aspect-oriented framework on top of flake-parts. Den replaces traditional NixOS module boilerplate (`mkEnableOption`, `mkIf`, manual imports) with a simpler pattern: **aspects** that auto-route config to the right platform.

## How It Works

### The Basics

Every `.nix` file under `modules/` is auto-loaded by `import-tree`. You never edit `flake.nix` — just add files.

Config is organized into three layers:

1. **Hosts** — machines (NixOS or darwin)
2. **Users** — people on those machines
3. **Aspects** — reusable config units (features, tools, services)

### Hosts and Users

Declared in `modules/hosts.nix`:

```nix
den.hosts.x86_64-linux.nixos.users.max = {};
den.hosts.aarch64-darwin.my-macbook.users.max = {};
den.hosts.x86_64-linux.ci-linux = {};           # no users (CI)
den.hosts.aarch64-darwin.ci-darwin = {};         # no users (CI)
```

Each host gets an aspect file in `modules/hosts/<name>.nix`. Each user gets an aspect file in `modules/aspects/<username>.nix`.

Den names are identity — the host name in `den.hosts` becomes the hostname (via `den.provides.hostname`) and the flake attribute (`.#nixos`, `.#my-macbook`).

### Class Keys

Aspects use **class keys** to route config to the right system:

| Key | Where it goes |
|-----|--------------|
| `os` | Both NixOS and darwin (auto-forwarded) |
| `nixos` | NixOS system config only |
| `darwin` | nix-darwin system config only |
| `homeManager` | Home Manager config (all platforms) |
| `hmLinux` | Home Manager on Linux only |
| `hmDarwin` | Home Manager on macOS only |

Example:

```nix
den.aspects.my-feature = {
  os = { ... }: { };                 # both NixOS and macOS
  nixos = { pkgs, ... }: { };       # only on NixOS
  darwin = { pkgs, ... }: { };      # only on macOS
  homeManager = { ... }: { };       # HM on both platforms
  hmLinux = { ... }: { };           # HM, Linux only
  hmDarwin = { ... }: { };          # HM, macOS only
};
```

Den figures out which blocks to apply based on the host's platform. You never write `mkIf` for platform checks.

## Current Setup

```
modules/
├── den.nix              # imports den framework + darwinConfigurations option
├── defaults.nix         # state versions + den.provides infrastructure (NO aspects)
├── schema.nix           # class forwarding (hmLinux/hmDarwin → homeManager)
├── hosts.nix            # host/user declarations
├── parts.nix            # supported systems
│
├── hosts/
│   ├── nixos.nix        # NixOS laptop (includes Linux desktop aspects)
│   ├── my-macbook.nix   # macOS (includes nix-settings, darwin-base, overlays, homebrew)
│   ├── ci-linux.nix     # GitHub Actions Linux runner (minimal, self-contained)
│   └── ci-darwin.nix    # GitHub Actions macOS runner (minimal, self-contained)
│
├── aspects/
│   ├── max.nix          # user config (includes all user-facing aspects)
│   │
│   │── # User aspects (homeManager — cross-platform)
│   ├── shell.nix        # fish, starship, atuin, bat, fzf, zoxide + fish functions + eza/git/claude aliases
│   ├── git.nix          # git config + histogram diffs, rerere, aliases (sync/co/br/ci/st)
│   ├── vim.nix          # vim + catppuccin (neovim in dev-tools, LazyVim managed externally)
│   ├── tmux.nix         # tmux + omarchy-style keybindings (Ctrl-a, prefix-free nav)
│   ├── ghostty.nix      # terminal (Ghostty, kitty graphics protocol)
│   ├── alacritty.nix    # terminal (inactive, kept as fallback)
│   ├── dev-tools.nix    # neovim, nodejs, gh, jq, ripgrep, eza, fd, lazygit, dust, fastfetch, gum (HM) + vscode (hmLinux)
│   ├── mcp.nix          # Claude MCP servers + sops secrets
│   │
│   │── # Host aspects (system-level)
│   ├── nix-settings.nix # nix config (os), GC (nixos/darwin separately)
│   ├── overlays.nix     # claude-code + antigravity overlays + packages (NixOS only)
│   ├── catppuccin.nix   # theming (nixos + homeManager + hmLinux for GTK/Qt)
│   ├── niri.nix         # compositor (NixOS + provides.to-users for config.kdl)
│   ├── noctalia.nix     # shell/bar (NixOS + provides.to-users for settings.json)
│   ├── greetd.nix       # display manager (NixOS)
│   ├── nvidia.nix       # GPU drivers (NixOS)
│   ├── audio.nix        # PipeWire (NixOS)
│   ├── bluetooth.nix    # Bluetooth (NixOS)
│   ├── printing.nix     # CUPS (NixOS)
│   ├── zram.nix         # compressed swap (NixOS)
│   ├── thunar.nix       # file manager (NixOS + provides.to-users for mime/xfce)
│   ├── fingerprint.nix  # fingerprint reader (NixOS)
│   ├── browsers.nix     # firefox (NixOS) + chrome (hmLinux)
│   ├── media.nix        # loupe, zathura + mime associations (hmLinux only)
│   ├── utilities.nix    # nvd, pfetch (homeManager) + anki, bubblewrap (hmLinux)
│   ├── darwin-base.nix  # trackpad, keyboard, Touch ID (darwin)
│   └── homebrew.nix     # declarative Homebrew casks (darwin)
│
hardware/
└── my-machine.nix       # hardware scan (outside modules/ — plain NixOS module)
```

## How to Add Things

### Add a new package

**Cross-platform user tool** — add to `homeManager.home.packages` in a user aspect:

```nix
homeManager = { pkgs, ... }: {
  home.packages = with pkgs; [
    my-new-tool    # ← installed on all platforms
  ];
};
```

**Linux-only user tool** — use `hmLinux` instead (important for packages with Linux-only deps):

```nix
hmLinux = { pkgs, ... }: {
  home.packages = [ pkgs.linux-only-tool ];
};
```

**macOS app** — add to Homebrew casks in `modules/aspects/homebrew.nix`.

**System service** — add to the relevant host aspect or create a new aspect with a `nixos` or `darwin` block.

### Add a new aspect

1. Create `modules/aspects/my-feature.nix`:

```nix
{ self, inputs, ... }: {
  den.aspects.my-feature = {
    # System-level (pick one or both)
    nixos = { pkgs, ... }: {
      services.my-service.enable = true;
    };

    # User-level (cross-platform)
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.my-tool ];
    };
  };
}
```

2. Include it in the right place:
   - **User tool**: add `den.aspects.my-feature` to `max.nix` includes
   - **System service**: add `den.aspects.my-feature` to the host's includes (e.g., `nixos.nix`)
   - **Both platforms**: use `os` for system config, `homeManager` for user config

That's it. `import-tree` auto-discovers the file.

### Add a new machine

1. Add to `modules/hosts.nix`:

```nix
den.hosts.x86_64-linux.my-server.users.max = {};
```

2. Create `modules/hosts/my-server.nix`:

```nix
{ den, ... }: {
  den.aspects.my-server = {
    includes = [
      den.aspects.nix-settings
      # ... whatever this machine needs
    ];

    nixos = { pkgs, ... }: {
      imports = [ ../../hardware/my-server.nix ];
      # boot, networking, etc.
    };
  };
}
```

3. Create `hardware/my-server.nix` with the hardware config (outside `modules/`).

4. Build: `nixos-rebuild switch --flake .#my-server`

Den handles user creation via `den.provides.define-user` and `den.provides.primary-user` — don't manually declare `users.users.*` in host aspects.

### Add a Homebrew cask (macOS)

Edit `modules/aspects/homebrew.nix`:

```nix
casks = [
  "visual-studio-code"
  "claude"
  "antigravity"
  "my-new-app"    # ← add here
];
```

## Key Patterns

### Host → User config flow (`provides.to-users`)

When a host aspect needs to push config to its users (like deploying a config file), use `provides.to-users`:

```nix
den.aspects.niri = {
  nixos = { pkgs, ... }: {
    programs.niri.enable = true;
  };

  provides.to-users.homeManager = { ... }: {
    xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  };
};
```

This scopes the config file to users on that host only — users on other hosts don't get it.

### Platform-specific Home Manager (`hmLinux` / `hmDarwin`)

For Home Manager config that should only apply on one platform:

```nix
den.aspects.catppuccin = {
  homeManager = { ... }: {
    # Applied on ALL platforms
    catppuccin.enable = true;
  };

  hmLinux = { ... }: {
    # Linux only — GTK, Qt, cursors
    gtk.enable = true;
    qt.enable = true;
  };
};
```

This works because `schema.nix` sets up forwarding that routes `hmLinux`/`hmDarwin` into `homeManager` with platform guards. Never use manual `mkIf pkgs.stdenv.isLinux` — use `hmLinux` instead.

### Cross-platform system config (`os`)

For system config that's identical on both NixOS and darwin:

```nix
den.aspects.nix-settings = {
  os = { ... }: {
    # Applied to BOTH nixos and darwin
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;
  };

  # Platform-specific differences go in separate blocks
  nixos = { ... }: { nix.gc.dates = "weekly"; };
  darwin = { ... }: { nix.gc.interval = { Weekday = 0; }; };
};
```

### Where to put things

| Config type | Where | Example |
|-------------|-------|---------|
| User CLI tools | `homeManager.home.packages` in user aspect | dev-tools.nix |
| User dotfiles | `homeManager.programs.*` in user aspect | git.nix, vim.nix, tmux.nix |
| Shell functions | `homeManager.programs.fish.functions` | shell.nix (ga, gwr, tdl, tsl, etc.) |
| Shell aliases | `homeManager.programs.fish.shellAliases` | shell.nix |
| Linux-only user tools | `hmLinux.home.packages` in user aspect | loupe, zathura, vscode |
| Linux-only user config | `hmLinux` in user aspect | xdg.mimeApps, GTK/Qt theming |
| macOS user apps | `homebrew.casks` | homebrew.nix |
| System services | `nixos`/`darwin` in host aspect | audio.nix, bluetooth.nix |
| Cross-platform system | `os` in host aspect | nix-settings.nix |
| Machine-specific config | `nixos`/`darwin` in host file | boot, networking |
| Host → user config | `provides.to-users.homeManager` | niri config.kdl |
| macOS system prefs | `darwin` in darwin-base aspect | trackpad, keyboard |
| Overlay-dependent pkgs | `nixos.environment.systemPackages` | overlays.nix |

### What NOT to put in defaults.nix

`defaults.nix` should only contain `den.provides.*` infrastructure and state versions. Never put aspects, user config, or feature includes there.

## Build Commands

```bash
just switch    # rebuild NixOS (.#nixos)
just test      # test without persisting
just check     # validate flake
just update    # update all inputs
just gc        # garbage collect
just diff      # show changes with nvd
```

## Niri and Noctalia

These use native config files deployed via `provides.to-users`:

- **Niri**: `modules/aspects/niri/config.kdl` — edit keybinds, monitor layout, borders directly in KDL
- **Noctalia**: `modules/aspects/noctalia/settings.json` — edit bar, widgets, themes directly in JSON

Changes to these files take effect on next `just switch`.
