# import-tree

## What it does

`import-tree` recursively imports every `.nix` file under a directory and
returns them as a **list of modules** that flake-parts can consume.

```nix
# flake.nix
outputs = inputs: inputs.flake-parts.lib.mkFlake
  { inherit inputs; }
  (inputs.import-tree ./modules);
#   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#   returns a list of all .nix files under modules/
#   flake-parts treats a list of modules the same as a single module
```

## What this means practically

You never touch `flake.nix` again. To add a new feature or a new machine:

1. Create a `.nix` file anywhere under `modules/`
2. Write a flake-parts module in it
3. Rebuild — it's automatically included

## The dendritic pattern

This is what the video calls a "dendritic" (tree-like) structure. Your
config grows outward from the root like branches:

```
modules/
  parts.nix           ← global settings (systems list)
  hosts/
    my-machine/
      default.nix     ← machine output
      configuration.nix
      hardware.nix
  features/
    niri.nix
    noctalia.nix
```

Each branch is independent. `niri.nix` doesn't know about `my-machine/`.
The machine pulls in features via `imports = [ self.nixosModules.niri ]`.

## Non-.nix files are ignored

`noctalia.json` sits in `modules/features/` but is not loaded by
import-tree — it's not a `.nix` file. It's read explicitly by `noctalia.nix`
via `builtins.readFile`.

## Directories without a default.nix

import-tree loads **every** `.nix` file, not just `default.nix`. A directory
like `my-machine/` with three files (`default.nix`, `configuration.nix`,
`hardware.nix`) gets all three loaded as separate flake-parts modules.
