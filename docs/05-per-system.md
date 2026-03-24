# perSystem

## What it is

`perSystem` is a flake-parts concept for outputs that vary by CPU architecture.
Packages, dev shells, and apps must be compiled — the same source produces
a different binary for `x86_64-linux` vs `aarch64-linux`.

Instead of writing:

```nix
packages.x86_64-linux.myNiri = ...;
packages.aarch64-linux.myNiri = ...;
# repeat for every arch
```

You write it once inside `perSystem` and flake-parts evaluates it for every
system in `config.systems`:

```nix
perSystem = { pkgs, ... }: {
  packages.myNiri = ...;  # evaluated for each system automatically
};
```

## parts.nix — the systems list

```nix
# modules/parts.nix
{
  config = {
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
```

This is the only place you declare which architectures exist. flake-parts
runs `perSystem` once per entry. If you only have x86 Linux machines, you
could trim this to just `"x86_64-linux"` to speed up evaluation.

## perSystem arguments

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myNiri = ...;
};
```

| Argument | What it is |
|---|---|
| `pkgs` | nixpkgs for the current system |
| `lib` | nixpkgs lib |
| `self'` | Your flake's outputs for the current system (see `03-self-and-self-prime.md`) |
| `system` | String like `"x86_64-linux"` |

## How your packages use it

**noctalia.nix** builds a package:

```nix
perSystem = { pkgs, ... }: {
  packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
    inherit pkgs;
    settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
  };
};
```

**niri.nix** builds a package that references noctalia:

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
    inherit pkgs;
    settings = {
      spawn-at-startup = [
        (lib.getExe self'.packages.myNoctalia)  # depends on noctalia
      ];
    };
  };
};
```

Because both are in `perSystem`, `self'.packages.myNoctalia` resolves to the
noctalia package for the **same architecture** as myNiri. No manual arch
string needed.

## Accessing perSystem outputs from a NixOS module

NixOS modules run outside `perSystem` — they don't receive `self'`. To
reference a per-system package, you use `pkgs.stdenv.hostPlatform.system`
to get the current arch string:

```nix
# niri.nix — NixOS module part
flake.nixosModules.niri = { pkgs, lib, ... }: {
  programs.niri = {
    package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    #                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #                         resolves to "x86_64-linux" at eval time
  };
};
```

This is the standard pattern for bridging the perSystem world (packages)
and the NixOS module world (system config).
