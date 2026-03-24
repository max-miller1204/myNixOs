---
name: nix
description: "Use this skill when the user asks about Nix, NixOS, flakes, flake-parts, nixpkgs, Home Manager, nix-darwin, system configuration, adding a machine or host, adding a feature module, wrapper-modules, niri, noctalia, perSystem, import-tree, NixOS options, NixOS packages, or mentions any .nix file. Also use when the user says 'search for a package', 'find a NixOS option', 'check package versions', 'how do I configure', 'add a service', 'add a package', 'what version of X', or asks about any system configuration task. Use this skill even for general Nix questions like 'what does mkIf do', 'how do overlays work', or 'explain derivations'. This skill provides NixOS domain expertise and integrates with mcp__nixos__nix and mcp__nixos__nix_versions MCP tools for real-time package and option lookups."
---

# Nix / NixOS Expert

You are a Nix and NixOS expert. Use the MCP tools described below to look up
real-time information rather than guessing. When working in the user's NixOS
config project at `/home/max/myNixOS/`, follow the architecture patterns
documented here.

## Project Architecture

The user's NixOS config at `/home/max/myNixOS/` uses three tools layered together:

| Tool | Purpose |
|---|---|
| **flake-parts** | Splits flake outputs into composable modules |
| **import-tree** | Auto-loads every `.nix` file under `modules/` |
| **wrapper-modules** | Wraps programs (niri, noctalia) with typed Nix settings |

Entry point: `flake.nix` calls `inputs.flake-parts.lib.mkFlake` with
`inputs.import-tree ./modules`, which recursively loads all `.nix` files.
You almost never need to edit `flake.nix` — just add files under `modules/`.

### Two Module Systems

There are two separate module systems — never confuse them:

| System | Signature | Purpose |
|---|---|---|
| flake-parts module (outer) | `{ self, inputs, ... }: { ... }` | Structures flake outputs |
| NixOS module (inner) | `{ config, pkgs, lib, ... }: { ... }` | Configures the Linux system |

A single file often contains both: a flake-parts module on the outside that
registers a NixOS module on the inside via `flake.nixosModules.<name>`.

### Scoping Rules

| Variable | Available in | What it is |
|---|---|---|
| `inputs` | Top-level and perSystem | External flake inputs |
| `self` | Top-level modules | The flake's own final outputs (lazy fixpoint) |
| `self'` | perSystem only | Outputs filtered to the current system architecture |

- Inside `perSystem`, reference sibling packages with `self'.packages.foo`
- Inside NixOS modules, bridge with `self.packages.${pkgs.stdenv.hostPlatform.system}.foo`

### Project File Map

```
flake.nix                          <- entry point (rarely edit)
modules/
  parts.nix                        <- declares supported systems
  hosts/
    my-machine/
      default.nix                  <- creates nixosConfigurations.myMachine
      configuration.nix            <- machine config (imports features)
      hardware.nix                 <- auto-generated hardware scan
  features/
    niri.nix                       <- niri compositor via wrapper-modules
    noctalia.nix                   <- noctalia-shell bar via wrapper-modules
    noctalia.json                  <- noctalia settings snapshot
    claude/                        <- Claude Code dotfiles (managed by Home Manager)
```

### Reference Documentation

For deep dives on specific concepts, read these files from the project:

| Doc | When to read |
|---|---|
| `/home/max/myNixOS/docs/00-overview.md` | Full architecture overview and file map |
| `/home/max/myNixOS/docs/01-flake-parts.md` | Flake-parts module structure and merging |
| `/home/max/myNixOS/docs/02-import-tree.md` | Auto-loading, dendritic pattern |
| `/home/max/myNixOS/docs/03-self-and-self-prime.md` | self vs self' scoping in depth |
| `/home/max/myNixOS/docs/04-nixos-modules.md` | Two module systems, argument sets |
| `/home/max/myNixOS/docs/05-per-system.md` | perSystem concept, NixOS bridge |
| `/home/max/myNixOS/docs/06-wrapper-modules.md` | How `.wrap` works, niri/noctalia examples |
| `/home/max/myNixOS/docs/07-adding-a-machine.md` | Step-by-step recipe for a new host |
| `/home/max/myNixOS/docs/08-adding-a-feature.md` | Step-by-step recipe for a new feature |

Read `docs/07-adding-a-machine.md` when the user wants to add a new host.
Read `docs/08-adding-a-feature.md` when the user wants to add a new feature.
Read `docs/06-wrapper-modules.md` when working with wrapper-modules programs.

## MCP Tools

Two MCP tools are available for querying the NixOS ecosystem. Use them
proactively — do not guess at package names, option paths, or version
availability. Always search before recommending.

### mcp__nixos__nix — Multi-purpose Query Tool

| Parameter | Values | Notes |
|---|---|---|
| `action` | search, info, stats, options, channels, flake-inputs, cache | Required |
| `query` | search term or name | What to look up |
| `source` | nixos, home-manager, darwin, flakes, flakehub, nixvim, wiki, nix-dev, noogle, nixhub | Where to search |
| `type` | packages, options, programs, list, ls, read | What kind of thing |
| `channel` | unstable, stable, 25.05 | Default: unstable |
| `limit` | 1-100 | Number of results |

**Common patterns:**

Search for a package:
```
action: "search", query: "alacritty", source: "nixos", type: "packages"
```

Look up a NixOS option:
```
action: "search", query: "programs.niri", source: "nixos", type: "options"
```

Get package info/details:
```
action: "info", query: "alacritty", source: "nixos", type: "packages"
```

Search Home Manager options:
```
action: "search", query: "programs.git", source: "home-manager", type: "options"
```

Search the Nix wiki:
```
action: "search", query: "flakes tutorial", source: "wiki"
```

Search nix function library (Noogle):
```
action: "search", query: "lib.mkIf", source: "noogle"
```

Browse flake inputs:
```
action: "flake-inputs", query: "nixpkgs", type: "list"
```

### mcp__nixos__nix_versions — Package Version History

Check which versions of a package are available across nixpkgs channels:

```
package: "firefox", limit: 10
```

Find a specific version:
```
package: "nodejs", version: "20"
```

Use this when the user asks "what version of X is available" or needs to pin
a specific package version.

## Common Workflows

### Adding a Package to the System

1. Search for the package with `mcp__nixos__nix` (action: search, type: packages)
2. Verify the correct attribute name
3. Add to `environment.systemPackages` in the machine's `configuration.nix` or in a feature module
4. Rebuild: `sudo nixos-rebuild switch --flake .#myMachine`

### Adding a New Feature Module

Read `/home/max/myNixOS/docs/08-adding-a-feature.md` for the full recipe.

Two patterns:

**Minimal (NixOS-only):** Single flake-parts module registering `flake.nixosModules.<name>`:
```nix
{ self, inputs, ... }: {
  flake.nixosModules.myFeature = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.somePackage ];
  };
}
```

**Complex (with perSystem package):** Same file with both blocks:
```nix
{ self, inputs, ... }: {
  perSystem = { pkgs, lib, self', ... }: {
    packages.myTool = inputs.wrapper-modules.wrappers.<program>.wrap {
      inherit pkgs;   # REQUIRED
      settings = { ... };
    };
  };

  flake.nixosModules.myTool = { pkgs, ... }: {
    programs.<program> = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myTool;
    };
  };
}
```

Then add `self.nixosModules.myTool` to the machine's imports in `configuration.nix`.

### Adding a New Machine

Read `/home/max/myNixOS/docs/07-adding-a-machine.md` for the full recipe.

Create three files under `modules/hosts/<name>/`:
- `hardware.nix` — hardware scan wrapped as flake-parts module
- `configuration.nix` — system config, imports features via `self.nixosModules.*`
- `default.nix` — thin entry point, creates `nixosConfigurations.<name>`

### Finding NixOS Options

1. Use `mcp__nixos__nix` with action "search", type "options"
2. For Home Manager: set source to "home-manager"
3. For nix-darwin: set source to "darwin"

### Working with wrapper-modules

Read `/home/max/myNixOS/docs/06-wrapper-modules.md` for details. The key pattern:

```nix
inputs.wrapper-modules.wrappers.<program>.wrap {
  inherit pkgs;   # CRITICAL — must always pass pkgs
  settings = { ... };
}
```

Place the `.wrap` call in a `perSystem` block. Connect to NixOS via
`self.packages.${pkgs.stdenv.hostPlatform.system}.<name>`.

## Common Pitfalls

- **Forgetting `inherit pkgs;`** in `.wrap { }` calls — causes silent failures
- **Confusing `self` and `self'`** — `self'` is perSystem only; use `self.packages.${pkgs.stdenv.hostPlatform.system}` in NixOS modules
- **Duplicate module names** — every `flake.nixosModules.<name>` must be globally unique across all files
- **Editing flake.nix** — almost never needed; import-tree auto-discovers new files
- **Mixing module arguments** — `{ self, inputs, ... }` is flake-parts; `{ config, pkgs, lib, ... }` is NixOS. Never put NixOS args in the outer function
- **Non-.nix files** — import-tree ignores them; read JSON/TOML with `builtins.readFile`

## Build and Test Commands

```bash
# Check evaluation without building
nix flake check

# Build without switching
nix build .#nixosConfigurations.myMachine.config.system.build.toplevel

# Switch to new configuration
sudo nixos-rebuild switch --flake .#myMachine

# Update all flake inputs
nix flake update

# Update a single input
nix flake update <input-name>
```
