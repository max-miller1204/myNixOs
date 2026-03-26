# wrapper-modules

Source: https://github.com/BirdeeHub/nix-wrapper-modules
Docs: https://birdeehub.github.io/nix-wrapper-modules/

## What it solves

Configuring programs like niri traditionally means writing raw config files
as Nix strings — error-prone and untyped. `wrapper-modules` provides a typed
Nix API for each supported program, then generates the correct config format.

Instead of:
```nix
programs.niri.config = ''
  spawn-at-startup { command = ["waybar"]; }
  layout { gaps 5; }
'';
```

You write structured Nix:
```nix
settings = {
  spawn-at-startup = [ { command = [ "waybar" ]; } ];
  layout.gaps = 5;
};
```

The wrapper handles serialization to whatever format the program expects.

## How `.wrap` works

```nix
inputs.wrapper-modules.wrappers.<program-name>.wrap {
  inherit pkgs;   # REQUIRED — tells it which nixpkgs to use
  settings = { ... };
}
```

This returns a **derivation** (a package) — the program compiled with your
settings baked in. You assign it to `perSystem.packages.myProgram`.

The `inherit pkgs;` line is critical. Without it, wrapper-modules doesn't
know which nixpkgs instance to use and will fail or silently use the wrong one.

## noctalia.nix

Noctalia settings are defined as an inline Nix attrset (no external JSON file):

```nix
perSystem = { pkgs, ... }: let
  noctaliaConfig = {
    settings = {
      settingsVersion = 57;
      bar = {
        barType = "simple";
        position = "left";
        monitors = [ "eDP-1" ];
        # ... hundreds of settings ...
      };
      idle = {
        enabled = true;
        screenOffTimeout = 600;
        lockTimeout = 660;
        suspendTimeout = 1800;
        # ...
      };
      # ...
    };
    state = {
      # Initial state seed — Noctalia overwrites this at runtime
      # ...
    };
  };
in {
  packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
    inherit pkgs;
    inherit (noctaliaConfig) settings;
  };
};
```

The settings were originally exported from a running Noctalia instance via:

```bash
noctalia-shell ipc call state all
```

Then converted from JSON to inline Nix attrsets. To update after changing
settings through the Noctalia UI, export the new JSON and convert it, or
edit the Nix attrset directly.

The `state` block (wallpaper paths, display geometry, etc.) is included as
an initial seed but Noctalia overwrites it at runtime — it will drift from
the declared values.

## niri.nix

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
    inherit pkgs;
    settings = {
      spawn-at-startup = [
        (lib.getExe self'.packages.myNoctalia)   # launch noctalia on start
      ];
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      input.keyboard.xkb.layout = "us,ua";
      layout.gaps = 5;
      binds = {
        "Mod+Return".spawn-sh = lib.getExe self'.packages.myAlacritty;
        "Mod+Q".close-window = null;
        "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
      };
    };
  };
};
```

Key things happening here:

- `lib.getExe pkg` — gets the main executable path from a package derivation.
  Equivalent to `"${pkg}/bin/${pkg.mainProgram}"` but more robust.
- `self'.packages.myNoctalia` — references the noctalia package defined in the
  same config, for the same system (see `03-self-and-self-prime.md`).
- The `binds` attribute set maps key combos to niri actions typed as Nix.

## alacritty.nix

```nix
perSystem = { pkgs, ... }: {
  packages.myAlacritty = inputs.wrapper-modules.wrappers.alacritty.wrap {
    inherit pkgs;
    settings = {
      window.opacity = 0.75;
      keyboard.bindings = [
        { key = "Return"; mods = "Shift"; chars = "\\u001B\\r"; }
      ];
    };
  };
};
```

Settings format: TOML (nested attribute sets). See `alacritty(5)` for options.

## git.nix

```nix
perSystem = { pkgs, ... }: {
  packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
    inherit pkgs;
    settings = {
      user = { name = "max"; email = "maxmiller1204@outlook.com"; };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };
};
```

Settings format: git INI (nested attrsets become INI sections). See `git-config(1)`.

## vim.nix

Vim uses a different interface — `vimrc` (raw string) and `plugins` (list of
packages) instead of `settings`:

```nix
perSystem = { pkgs, ... }: {
  packages.myVim = inputs.wrapper-modules.wrappers.vim.wrap {
    inherit pkgs;
    vimrc = ''
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
    '';
  };
};
```

## Connecting the wrapped package to NixOS

The wrapper produces a package. To make NixOS actually use it, you create a
toggleable NixOS module with `mkEnableOption`:

```nix
flake.nixosModules.niri = { pkgs, lib, config, ... }: {
  options.features.niri.enable = lib.mkEnableOption "Niri compositor";

  config = lib.mkIf config.features.niri.enable {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };
};
```

Same file, two blocks: one `perSystem` block that builds the package, one
`flake.nixosModules` block that installs it. The feature is enabled in the
host's `configuration.nix`:

```nix
features.niri.enable = true;
```

All feature modules follow this pattern — they are imported but dormant by
default, and explicitly enabled per-host.

## Finding available wrappers

```bash
nix eval github:BirdeeHub/nix-wrapper-modules#wrappers --apply 'w: builtins.attrNames w'
```

Currently used in this config: niri, noctalia-shell, alacritty, git, vim.

Note: Catppuccin Mocha colors are manually added to `alacritty.nix` (full
palette) and `niri.nix` (border colors) since wrapper-modules packages
bypass Home Manager and can't be auto-themed by catppuccin/nix.

Full list and docs: https://github.com/BirdeeHub/nix-wrapper-modules
