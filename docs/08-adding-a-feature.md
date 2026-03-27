# Recipe: Adding a New Feature Module

A "feature" is anything you want to enable on one or more machines:
a compositor, a shell setup, a service, a set of packages.

## Minimal feature (NixOS packages/services only)

Create `modules/features/my-feature.nix`:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myFeature = { pkgs, lib, config, ... }: {
    options.features.myFeature.enable = lib.mkEnableOption "My feature";

    config = lib.mkIf config.features.myFeature.enable {
      environment.systemPackages = with pkgs; [
        ripgrep
        fd
      ];
    };
  };
}
```

Enable it in your machine's `configuration.nix`:

```nix
imports = [
  self.nixosModules.myFeature    # add this
];

features.myFeature.enable = true;  # turn it on
```

## Feature with a per-system package (wrapper-modules or custom derivation)

If your feature needs to build something (like niri or noctalia), use both
`perSystem` and `flake.nixosModules` in the same file:

```nix
{ self, inputs, ... }: {

  # 1. Build the package (runs per architecture)
  perSystem = { pkgs, lib, self', ... }: {
    packages.myTool = inputs.wrapper-modules.wrappers.sometool.wrap {
      inherit pkgs;
      settings = { ... };
    };
  };

  # 2. Install it via a toggleable NixOS module
  flake.nixosModules.myTool = { pkgs, lib, config, ... }: {
    options.features.myTool.enable = lib.mkEnableOption "My tool";

    config = lib.mkIf config.features.myTool.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myTool
      ];
    };
  };

}
```

Currently, wrapper-modules is used for niri and noctalia-shell.

## Feature with Home Manager config

If your feature needs to set per-user config (shell aliases, dotfiles, HM programs),
extend `home-manager.users` from your module using `config.my.variables.username`:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myFeature = { pkgs, lib, config, ... }: {
    options.features.myFeature.enable = lib.mkEnableOption "My feature";

    config = lib.mkIf config.features.myFeature.enable {
      # NixOS-level config
      programs.some-program.enable = true;

      # Home Manager-level config (merged with other modules)
      home-manager.users.${config.my.variables.username} = {
        programs.some-program = {
          enable = true;
          settings = { ... };
        };
      };
    };
  };
}
```

Multiple modules can set `home-manager.users.max` — NixOS merges them automatically
(unless there's a conflict, in which case use `lib.mkForce`).

This is the pattern used by alacritty.nix, vim.nix, git.nix, browsers.nix, media.nix,
shell.nix, catppuccin.nix, and thunar.nix.

## Checklist

- [ ] Module name is unique (e.g., `myFeatureName` — no conflicts with existing names)
- [ ] `inherit pkgs;` is present when calling `.wrap { }` from wrapper-modules
- [ ] Feature is added to `imports` in the machine's `configuration.nix`
- [ ] `features.myFeature.enable = true;` is set in the machine's `configuration.nix`
- [ ] If referencing another per-system package: use `self'` inside `perSystem`,
      use `self.packages.${pkgs.stdenv.hostPlatform.system}` inside NixOS modules

## Testing before switching

```bash
# Check evaluation (fast, no build)
nix flake check

# Build without switching
nix build .#nixosConfigurations.myMachine.config.system.build.toplevel

# Switch
sudo nixos-rebuild switch --flake .#myMachine
```

## Using centralized variables

Access shared values via `config.my.variables.*` inside NixOS modules:

```nix
config = lib.mkIf config.features.myFeature.enable {
  users.users.${config.my.variables.username}.extraGroups = [ "docker" ];
  time.timeZone = config.my.variables.timezone;
  # Available: username, email, editor, terminal, browser, monitor,
  #            secondaryMonitor, location, wallpaperDir, avatarPath,
  #            flakePath, timezone, locale, font,
  #            catppuccin.flavor, catppuccin.accent
};
```

## Practical notes

- New module files must be `git add`-ed before `nix flake check` or rebuild can see them (flakes only read git-tracked files).
- On current nixpkgs with NVIDIA driver `>= 560`, you must set `hardware.nvidia.open` explicitly in your NVIDIA feature module (`true` for open kernel module, or `false` for proprietary).
