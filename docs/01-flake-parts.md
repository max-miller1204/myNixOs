# flake-parts

## The problem it solves

A raw NixOS flake's `outputs` function returns one big attribute set:

```nix
outputs = { nixpkgs, ... }: {
  nixosConfigurations.myMachine = ...;
  packages.x86_64-linux.myPkg = ...;
  # everything in one place, grows unbounded
};
```

There is no way to split this across files — it's one function call.

`flake-parts` introduces a **module system for flake outputs**. Instead of
one giant function, you write small modules that each contribute a slice of
the outputs. The framework merges them.

## What it looks like in your flake

```nix
# flake.nix
outputs = inputs: inputs.flake-parts.lib.mkFlake
  { inherit inputs; }
  (inputs.import-tree ./modules);   # <-- the "module" argument
```

`mkFlake` takes:
1. `{ inherit inputs; }` — passes your inputs into every module
2. A module (or list of modules) that define what goes in the outputs

## What a flake-parts module looks like

Every file under `modules/` is a flake-parts module. The signature is:

```nix
{ self, inputs, ... }: {
  # top-level options come from the flake-parts schema
  flake.nixosConfigurations = { ... };
  flake.nixosModules = { ... };
  perSystem = { pkgs, ... }: { ... };
  config.systems = [ ... ];
}
```

The special arguments available at the top level are:

| Argument | What it is |
|---|---|
| `self` | The flake itself (its outputs, once evaluated) |
| `inputs` | All flake inputs (nixpkgs, flake-parts, etc.) |

## Top-level output namespaces

| Key | What goes here |
|---|---|
| `flake.*` | Anything that becomes a direct flake output: `nixosConfigurations`, `nixosModules`, `overlays`, `lib`, etc. |
| `perSystem` | Outputs that are per-architecture: `packages`, `devShells`, `apps`, etc. |
| `config.systems` | The list of architectures to evaluate `perSystem` for |

## Merging

All modules are merged. If two files both set `flake.nixosModules`, the
attribute sets are merged (unioned). If they set the same key it's an error,
just like NixOS module option conflicts.

```nix
# file A
{ ... }: { flake.nixosModules.foo = ...; }

# file B
{ ... }: { flake.nixosModules.bar = ...; }

# result
flake.nixosModules = { foo = ...; bar = ...; }
```
