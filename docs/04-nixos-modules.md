# NixOS Modules and nixosConfigurations

## Two module systems in play

There are two separate module systems here and they are easy to confuse:

| System | Purpose | Lives in |
|---|---|---|
| flake-parts modules | Structure flake outputs | `{ self, inputs, ... }: { ... }` |
| NixOS modules | Configure a Linux system | `{ config, pkgs, lib, ... }: { ... }` |

Your files often contain **both** — a flake-parts module on the outside that
registers a NixOS module on the inside.

## How a NixOS configuration is built

```nix
# default.nix — flake-parts module
{ self, inputs, ... }: {
  flake.nixosConfigurations.myMachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMachineConfiguration
    ];
  };
}
```

`nixpkgs.lib.nixosSystem` takes a list of NixOS modules and evaluates them
together. The result is a fully configured system you can build with:

```bash
nixos-rebuild switch --flake .#myMachine
```

## How NixOS modules are registered

```nix
# configuration.nix — flake-parts module that adds a NixOS module
{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
    # This is a NixOS module (different argument set)
    networking.hostName = "nixos";
    environment.systemPackages = with pkgs; [ vim ];
    # ...
  };
}
```

`flake.nixosModules` is a flake-parts output — it's just an attribute set of
NixOS modules stored in your flake. You can reference them anywhere via `self`.

## The import chain for your machine

```
nixosConfigurations.myMachine
  +-- modules: [ self.nixosModules.myMachineConfiguration ]
       +-- myMachineConfiguration imports:
            |-- self.nixosModules.myMachineHardware   (hardware.nix)
            |-- self.nixosModules.variables            (variables.nix — centralized config)
            |-- self.nixosModules.overlays              (overlays.nix)
            |-- self.nixosModules.niri                  (niri.nix)
            |-- self.nixosModules.homeManager           (home.nix — includes HM SOPS secrets)
            |-- self.nixosModules.alacritty             (alacritty.nix — HM programs.alacritty)
            |-- self.nixosModules.git                   (git.nix — HM programs.git)
            |-- self.nixosModules.vim                   (vim.nix — HM programs.vim)
            |-- self.nixosModules.nvidia                (nvidia.nix)
            |-- self.nixosModules.zram                  (zram.nix)
            |-- self.nixosModules.nh                    (nh.nix)
            |-- self.nixosModules.shell                 (shell.nix — Fish/Starship/Atuin)
            |-- self.nixosModules.catppuccin            (catppuccin.nix)
            |-- self.nixosModules.thunar                (thunar.nix)
            |-- self.nixosModules.browsers              (browsers.nix — Firefox/Chrome)
            |-- self.nixosModules.devTools               (dev-tools.nix — codex, vscode, etc.)
            |-- self.nixosModules.media                  (media.nix — loupe, zathura)
            |-- self.nixosModules.utilities              (utilities.nix — anki, nvd, etc.)
            |-- self.nixosModules.audio                  (audio.nix — PipeWire + sox)
            |-- self.nixosModules.greetd                 (greetd.nix — display manager)
            |-- self.nixosModules.bluetooth              (bluetooth.nix)
            +-- self.nixosModules.printing               (printing.nix)
```

Notice: `default.nix` only lists `myMachineConfiguration`. That module then
pulls in hardware and features via its `imports` list. This is the intended
pattern — `default.nix` is a thin entry point; the real imports live in
`configuration.nix`.

Secrets (Context7, YouTube API keys) are managed at the Home Manager level
inside `home.nix` using `sops-nix`'s Home Manager module, not system-level.

## Toggleable features with mkEnableOption

Feature modules use `mkEnableOption` so they can be toggled per-host:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myFeature = { pkgs, lib, config, ... }: {
    options.features.myFeature.enable = lib.mkEnableOption "My feature";

    config = lib.mkIf config.features.myFeature.enable {
      # actual config goes here
    };
  };
}
```

Features are imported but dormant by default. Enable them in the host config:

```nix
features.niri.enable = true;
features.homeManager.enable = true;
features.alacritty.enable = true;
features.browsers.enable = true;
features.devTools.enable = true;
features.audio.enable = true;
# etc.
```

All custom toggles live under the `features.*` namespace to avoid clashing
with upstream NixOS options.

## NixOS module arguments vs flake-parts module arguments

```nix
# flake-parts module arguments (outer function)
{ self, inputs, ... }:

# NixOS module arguments (inner function)
{ config, pkgs, lib, modulesPath, ... }:
```

You can use both in the same file:

```nix
{ self, inputs, ... }: {                         # flake-parts args
  flake.nixosModules.niri = { pkgs, lib, ... }: { # NixOS args
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      #          ^^^ flake-parts self, used inside NixOS module
    };
  };
}
```

`self` is closed over from the outer scope — it's not a NixOS module argument.

## hardware.nix — the hardware scan

`hardware.nix` contains the output of `nixos-generate-config`. It registers
as `flake.nixosModules.myMachineHardware` and sets machine-specific things:

- kernel modules (`boot.initrd.availableKernelModules`)
- filesystem UUIDs (`fileSystems."/".device`)
- host platform (`nixpkgs.hostPlatform`)

You generally don't edit this file by hand. If you add new hardware, re-run
`nixos-generate-config` and copy the hardware section.
