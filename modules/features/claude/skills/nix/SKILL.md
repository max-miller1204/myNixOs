---
name: nix
description: "Use this skill when the user asks about Nix, NixOS, flakes, flake-parts, nixpkgs, Home Manager, nix-darwin, system configuration, adding a machine or host, adding a feature module, wrapper-modules, niri, noctalia, perSystem, import-tree, NixOS options, NixOS packages, or mentions any .nix file. Also use when the user says 'search for a package', 'find a NixOS option', 'check package versions', 'how do I configure', 'add a service', 'add a package', 'what version of X', or asks about any system configuration task. Use this skill even for general Nix questions like 'what does mkIf do', 'how do overlays work', or 'explain derivations'. This skill provides NixOS domain expertise and integrates with mcp__nixos__nix and mcp__nixos__nix_versions MCP tools for real-time package and option lookups."
---

# Nix / NixOS Expert

Use the MCP tools below for real-time lookups — never guess package names, option paths, or versions. When working in `/home/max/myNixOS/`, follow the patterns here.

## Project Architecture (Quick Reference)

The config uses **flake-parts** + **import-tree** + **wrapper-modules**. Entry point is `flake.nix` → `inputs.import-tree ./modules` which auto-discovers all `.nix` files. You almost never edit `flake.nix` — just add files under `modules/`.

**Two module systems** coexist in most files:
- **Outer** (flake-parts): `{ self, inputs, ... }: { ... }` — structures flake outputs
- **Inner** (NixOS): `{ config, pkgs, lib, ... }: { ... }` — configures the system

Never mix their arguments. `self`/`inputs` belong to the outer function; `config`/`pkgs`/`lib` belong to the inner.

**Scoping**: `self'` exists only in `perSystem` blocks. In NixOS modules, bridge with `self.packages.${pkgs.stdenv.hostPlatform.system}.foo`.

**Centralized variables**: All modules use `config.my.variables.*` (username, timezone, editor, etc.) instead of hardcoded values. Read `docs/11-centralized-variables.md` for the full list.

## Feature Module Pattern

Every feature module follows this shape — note the `mkEnableOption` gate:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.myFeature = { pkgs, lib, config, ... }: {
    options.features.myFeature.enable = lib.mkEnableOption "my feature";

    config = lib.mkIf config.features.myFeature.enable {
      # Use centralized variables, not hardcoded "max"
      home-manager.users.${config.my.variables.username} = { ... };
    };
  };
}
```

For features needing a custom package (wrapper-modules), add a `perSystem` block in the same file. Read `docs/06-wrapper-modules.md` for the `.wrap` pattern — the critical thing is always passing `inherit pkgs;`.

Then import `self.nixosModules.myFeature` in the machine's `configuration.nix`.

## Reference Docs

Read these from `/home/max/myNixOS/docs/` when you need depth on a topic:

| Doc | When to read |
|---|---|
| `00-overview.md` | Full architecture and file map |
| `01-flake-parts.md` | Flake-parts module structure |
| `02-import-tree.md` | Auto-loading / dendritic pattern |
| `03-self-and-self-prime.md` | self vs self' scoping |
| `04-nixos-modules.md` | Two module systems in detail |
| `05-per-system.md` | perSystem, NixOS bridge |
| `06-wrapper-modules.md` | `.wrap` pattern (niri, noctalia) |
| `07-adding-a-machine.md` | New host recipe |
| `08-adding-a-feature.md` | New feature recipe |
| `09-claude-code-mcp.md` | MCP server setup in Home Manager |
| `09-context7-secrets.md` | Sops-nix secret management |
| `11-centralized-variables.md` | `config.my.variables.*` system |
| `12-justfile-commands.md` | Build/deploy shortcuts |
| `13-shell-setup.md` | Fish, Starship, Atuin config |
| `14-catppuccin-theming.md` | Catppuccin theming strategy |

## MCP Tools

### mcp__nixos__nix — Package/Option Lookup

Use `action` + `source` + `type` to query. Common combos:

- **Find a package**: `action: "search", query: "alacritty", source: "nixos", type: "packages"`
- **Package details**: `action: "info", query: "alacritty", source: "nixos", type: "packages"`
- **NixOS option**: `action: "search", query: "programs.niri", source: "nixos", type: "options"`
- **Home Manager option**: `action: "search", query: "programs.git", source: "home-manager", type: "options"`
- **Nix function (Noogle)**: `action: "search", query: "lib.mkIf", source: "noogle"`
- **Wiki**: `action: "search", query: "flakes tutorial", source: "wiki"`

### mcp__nixos__nix_versions — Version History

Check versions across channels: `package: "firefox"`. Filter: `package: "nodejs", version: "20"`.

## Build Commands

Use `just` from the repo root (see `docs/12-justfile-commands.md` for full list):

```bash
just switch    # rebuild and activate (.#nixos)
just test      # activate without adding to boot menu
just check     # evaluate flake for errors
just update    # update all flake inputs
just gc        # garbage collect old generations
just diff      # show diff with nvd
```

Or use `nh os switch` which auto-detects the flake path.

## Common Pitfalls

- **Forgetting `inherit pkgs;`** in `.wrap {}` — causes silent failures
- **Mixing module arguments** — `self`/`inputs` are outer; `config`/`pkgs`/`lib` are inner
- **Hardcoding usernames** — use `config.my.variables.username` instead
- **Editing flake.nix** — almost never needed; import-tree auto-discovers
- **Using raw nix commands** — prefer `just switch` over `sudo nixos-rebuild switch --flake .#nixos`
- **The flake attribute is `.#nixos`** — not the machine hostname
