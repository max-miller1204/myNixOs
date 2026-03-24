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
  self.nixosModules.myMachineHardware
  self.nixosModules.niri
  self.nixosModules.myFeature    # ← add this
];

features.myFeature.enable = true;  # ← turn it on
```

## Feature with a per-system package (wrapper-modules or custom derivation)

If your feature needs to build something (like niri or alacritty), use both
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
