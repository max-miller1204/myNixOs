# self, self', and inputs

These are the three main arguments you'll use in every module. They look
similar but come from different scopes.

## `inputs` — your flake inputs

```nix
{ self, inputs, ... }:
```

`inputs` is the attribute set of everything declared in `flake.nix`'s
`inputs` block:

```nix
inputs.nixpkgs        # github:nixos/nixpkgs/nixos-unstable
inputs.flake-parts    # github:hercules-ci/flake-parts
inputs.import-tree    # github:vic/import-tree
inputs.wrapper-modules # github:BirdeeHub/nix-wrapper-modules
```

Use `inputs` when you need something from an external source:
- `inputs.nixpkgs.lib.nixosSystem { ... }` to build a system
- `inputs.wrapper-modules.wrappers.niri.wrap { ... }` to wrap a program

## `self` — your own flake's outputs

`self` is a reference back to **your own flake's final output attribute set**.
It's available at the top level of every flake-parts module:

```nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.myMachine = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMachineConfiguration  # ← referring to something
    ];                                            #   defined in another file
  };
}
```

Because all files are merged before evaluation, `self.nixosModules.myMachineConfiguration`
resolves to what `configuration.nix` defined — even though `default.nix`
doesn't import `configuration.nix` directly.

This is how the dendritic pattern works: modules communicate through `self`,
not through file imports.

### Self is lazy

`self` is a lazy fixpoint. It can refer to its own outputs without causing
infinite recursion because Nix only evaluates what's needed.

## `self'` — current-system self (inside perSystem)

Inside a `perSystem` block, you get a different argument: `self'` (self-prime).

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
    settings = {
      spawn-at-startup = [
        (lib.getExe self'.packages.myNoctalia)  # ← self' here
      ];
    };
  };
};
```

`self'` is `self` filtered to **the current system** (`x86_64-linux`, etc.).
It lets you reference other packages in the same `perSystem` scope without
manually specifying the architecture:

| Expression | What it gives you |
|---|---|
| `self.packages.x86_64-linux.myNoctalia` | Explicitly x86_64 |
| `self'.packages.myNoctalia` | Current system (same thing, cleaner) |

Use `self'` inside `perSystem` whenever you want to reference another package
you've defined in the same config.

## Quick reference

| Variable | Available in | What it is |
|---|---|---|
| `inputs` | Top-level modules, perSystem | External flake inputs |
| `self` | Top-level modules | Your flake's entire output |
| `self'` | perSystem only | Your flake's outputs for current system |
