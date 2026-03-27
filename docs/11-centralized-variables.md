# Centralized Variables

## What it is

`modules/features/variables.nix` defines shared configuration values under
`config.my.variables.*` that any NixOS module can read. This eliminates
hardcoded values like `"max"`, `"America/New_York"`, etc. scattered across files.

## Available variables

| Variable | Default | Used by |
|---|---|---|
| `my.variables.username` | `"max"` | configuration.nix, home.nix, shell.nix, nh.nix, catppuccin.nix, git.nix, alacritty.nix, vim.nix, etc. |
| `my.variables.email` | `"maxmiller1204@outlook.com"` | git.nix |
| `my.variables.editor` | `"vim"` | (available for future use) |
| `my.variables.terminal` | `"alacritty"` | thunar.nix |
| `my.variables.browser` | `"firefox"` | (available for future use) |
| `my.variables.monitor` | `"eDP-1"` | (available for future use) |
| `my.variables.secondaryMonitor` | `"DP-3"` | (mirrors let-bindings in niri.nix, noctalia.nix) |
| `my.variables.location` | `"Blacksburg"` | (mirrors let-binding in noctalia.nix) |
| `my.variables.wallpaperDir` | `"/home/max/Pictures/Wallpapers"` | (mirrors let-binding in noctalia.nix) |
| `my.variables.avatarPath` | `"/home/max/.face"` | (mirrors let-binding in noctalia.nix) |
| `my.variables.flakePath` | `"/home/max/myNixOS"` | nh.nix |
| `my.variables.timezone` | `"America/New_York"` | configuration.nix |
| `my.variables.locale` | `"en_US.UTF-8"` | configuration.nix |
| `my.variables.font` | `"JetBrains Mono"` | fonts in configuration.nix |
| `my.variables.catppuccin.flavor` | `"mocha"` | catppuccin.nix |
| `my.variables.catppuccin.accent` | `"mauve"` | catppuccin.nix |

Note: niri.nix and noctalia.nix use `perSystem` blocks which cannot access
NixOS module config. Their monitor names, location, and paths are defined as
`let` bindings at the flake-parts module level, mirroring the variable defaults.

## How to use in a module

Inside any NixOS module (the inner `{ config, pkgs, ... }:` function):

```nix
config = lib.mkIf config.features.myFeature.enable {
  users.users.${config.my.variables.username}.extraGroups = [ "docker" ];
  home-manager.users.${config.my.variables.username} = { ... };
};
```

## How it works

The module defines `options.my.variables.*` with `lib.mkOption` and sensible
defaults. It has no `enable` gate — it's always active once imported. It must
be imported in each machine's `configuration.nix`:

```nix
imports = [
  self.nixosModules.variables
  # ...
];
```

## Overriding per-machine

To change a value for a specific machine, set it in that machine's `configuration.nix`:

```nix
my.variables.username = "alice";
my.variables.timezone = "Europe/London";
```

All modules that read `config.my.variables.*` will pick up the override automatically.
