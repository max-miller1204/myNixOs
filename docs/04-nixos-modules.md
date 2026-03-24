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
  └─ modules: [ self.nixosModules.myMachineConfiguration ]
       └─ myMachineConfiguration imports:
            ├─ self.nixosModules.myMachineHardware   (hardware.nix)
            └─ self.nixosModules.niri                (niri.nix)
```

Notice: `default.nix` only lists `myMachineConfiguration`. That module then
pulls in hardware and features via its `imports` list. This is the intended
pattern — `default.nix` is a thin entry point; the real imports live in
`configuration.nix`.

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
