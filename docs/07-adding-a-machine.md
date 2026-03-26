# Recipe: Adding a Second Machine

## 1. Generate hardware config on the new machine

Boot NixOS on the new machine (or use an existing install) and run:

```bash
nixos-generate-config --show-hardware-config
```

Copy the output — you'll need it in step 3.

## 2. Create the directory

```bash
mkdir -p modules/hosts/my-laptop
```

## 3. Create the three files

### modules/hosts/my-laptop/hardware.nix

Paste the hardware config, wrapped as a flake-parts module:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myLaptopHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" ];
    # ... rest of hardware-scan output ...

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
```

### modules/hosts/my-laptop/configuration.nix

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myLaptopConfiguration = { pkgs, ... }: {
    imports = [
      self.nixosModules.myLaptopHardware
      self.nixosModules.variables      # centralized variables (always include)
      self.nixosModules.niri           # reuse existing features
      self.nixosModules.alacritty
      self.nixosModules.git
      self.nixosModules.vim
      self.nixosModules.homeManager    # includes HM-level SOPS secrets
      self.nixosModules.shell          # Fish + Starship + Atuin
      self.nixosModules.catppuccin     # system-wide theming
      self.nixosModules.zram
      self.nixosModules.nh
      self.nixosModules.nvidia         # only if NVIDIA hardware
    ];

    # Toggle features on/off per machine
    features.niri.enable = true;
    features.alacritty.enable = true;
    features.git.enable = true;
    features.vim.enable = true;
    features.homeManager.enable = true;
    features.shell.enable = true;
    features.catppuccin.enable = true;
    features.zram.enable = true;
    features.nh.enable = true;
    features.nvidia.enable = true;  # set false if no NVIDIA

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "my-laptop";
    # ... rest of your config ...

    system.stateVersion = "25.11";
  };
}
```

### modules/hosts/my-laptop/default.nix

```nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.myLaptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myLaptopConfiguration
    ];
  };
}
```

## 4. That's it

import-tree picks up the new files automatically. Build with:

```bash
nixos-rebuild switch --flake .#myLaptop
```

## Notes

- Module names (`myLaptopHardware`, `myLaptopConfiguration`) must be globally
  unique across all files. A common convention is `<machineName>Hardware`,
  `<machineName>Configuration`.
- Features like `niri` are reusable — import `self.nixosModules.niri` in any
  machine's configuration.
- The hardware module name used in `configuration.nix` must match exactly what
  `hardware.nix` registers in `flake.nixosModules`.
