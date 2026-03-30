---
name: nix
description: "Use this skill when the user asks about Nix, NixOS, flakes, flake-parts, nixpkgs, Home Manager, nix-darwin, system configuration, adding a machine or host, den, aspects, contexts, class routing, perSystem, import-tree, NixOS options, NixOS packages, or mentions any .nix file. Also use when the user says 'search for a package', 'find a NixOS option', 'check package versions', 'how do I configure', 'add a service', 'add a package', 'what version of X', or asks about any system configuration task. Use this skill even for general Nix questions like 'what does mkIf do', 'how do overlays work', or 'explain derivations'. This skill provides NixOS domain expertise and integrates with mcp__nixos__nix and mcp__nixos__nix_versions MCP tools for real-time package and option lookups."
---

# Nix / NixOS Expert

Use the MCP tools below for real-time lookups — never guess package names, option paths, or versions. When working in `/home/max/myNixOS/`, follow the patterns here.

## Project Architecture (Quick Reference)

The config uses **flake-parts** + **import-tree** + **den** (aspect-oriented framework). Entry point is `flake.nix` → `inputs.import-tree ./modules` which auto-discovers all `.nix` files. You almost never edit `flake.nix` — just add files under `modules/`.

**Den** sits on top of flake-parts and provides:
- **Aspects**: reusable configuration units (no `mkEnableOption` boilerplate)
- **Context pipeline**: host → user → home evaluation chain
- **Class routing**: `nixos`, `darwin`, `homeManager` keys in aspects auto-route to the right system
- **Includes**: aspects compose via `includes = [ den.aspects.foo den.aspects.bar ]`

**Two module systems** coexist:
- **Outer** (flake-parts): `{ den, inputs, ... }: { ... }` — structures flake outputs and den config
- **Inner** (NixOS/HM): `{ config, pkgs, lib, ... }: { ... }` — configures the system

Never mix their arguments. `den`/`inputs` belong to the outer function; `config`/`pkgs`/`lib` belong to the inner.

## Den Aspect Pattern

Every feature is an aspect — no `mkEnableOption`, no `mkIf`, no manual imports:

```nix
# modules/aspects/my-feature.nix
{ den, ... }: {
  den.aspects.my-feature = {
    # NixOS system-level config
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.hello ];
    };

    # Home Manager user-level config
    homeManager = { pkgs, ... }: {
      programs.git.enable = true;
    };

    # Include other aspects
    includes = [
      den.aspects.some-dependency
    ];
  };
}
```

To use a feature: add it to a host or user aspect's `includes` list.

## Host and User Structure

**Hosts are declared** in `modules/hosts.nix`:
```nix
den.hosts.x86_64-linux.my-machine.users.max = {};
```

**Host aspects** define machine-specific config in `modules/hosts/<name>.nix`:
```nix
{ den, ... }: {
  den.aspects.my-machine = {
    includes = [ den.aspects.niri den.aspects.nvidia ... ];
    nixos = { pkgs, ... }: { /* boot, networking, etc. */ };
  };
}
```

**User aspects** define user-specific config in `modules/aspects/<username>.nix`:
```nix
{ den, inputs, ... }: {
  den.aspects.max = {
    includes = [ den.aspects.shell den.aspects.git ... ];
    homeManager = { config, ... }: { /* user config */ };
  };
}
```

## Den Provides (Built-in Batteries)

Den has built-in provides for common patterns:
- `den.provides.primary-user` — makes the user an admin (wheel group)
- `(den.provides.user-shell "fish")` — sets the user's login shell
- `den._.mutual-provider` — enables host↔user bidirectional config

Used in aspect includes:
```nix
den.aspects.max.includes = [
  den.provides.primary-user
  (den.provides.user-shell "fish")
];
```

## Context Pipeline & Class Routing

Den evaluates aspects through contexts:
1. **Host context** `{ host }` — host aspect's `nixos`/`darwin` blocks
2. **User context** `{ host, user }` — user aspect's `homeManager` block
3. **Home context** `{ host, user, home }` — standalone home configs

**Class keys** in aspects:
- `nixos = { ... }:` — applied to NixOS hosts
- `darwin = { ... }:` — applied to nix-darwin hosts (future)
- `homeManager = { ... }:` — applied to all users on all hosts

**If config doesn't appear, check:**
1. Is the aspect included in the host or user's `includes`?
2. Is the class key correct? (`nixos` vs `homeManager` vs `darwin`)
3. For parametric functions: are the expected args (`host`, `user`) in scope?

## Key Files

| File | Purpose |
|---|---|
| `modules/den.nix` | Den bootstrap + ctx includes |
| `modules/hosts.nix` | Host/user declarations |
| `modules/defaults.nix` | Shared defaults (stateVersion, global includes) |
| `modules/schema.nix` | Class configuration (homeManager by default) |
| `modules/hosts/my-machine.nix` | Host aspect (hardware, boot, networking) |
| `modules/aspects/max.nix` | User aspect (HM setup, claude dotfiles, sops) |
| `modules/aspects/*.nix` | Feature aspects (git, shell, vim, niri, etc.) |
| `hardware/my-machine.nix` | Hardware config (outside modules/ — plain NixOS module) |

## Adding a New Feature

1. Create `modules/aspects/my-feature.nix`
2. Add `nixos = { ... }:` for system config and/or `homeManager = { ... }:` for user config
3. Add `den.aspects.my-feature` to the appropriate host or user `includes`
4. That's it — import-tree auto-discovers the file

## Adding a New Machine

1. Add to `modules/hosts.nix`: `den.hosts.<system>.<name>.users.<user> = {};`
2. Create `modules/hosts/<name>.nix` with the host aspect
3. Create `hardware/<name>.nix` with hardware config (outside `modules/`)
4. Build with: `nixos-rebuild switch --flake .#<name>`

## Niri and Noctalia

Niri and noctalia use **native config files** (not wrapper-modules):
- Niri: `modules/aspects/niri/config.kdl` (KDL format) deployed via `xdg.configFile`
- Noctalia: `modules/aspects/noctalia/settings.json` (JSON) deployed via `xdg.configFile`

To modify keybinds/settings, edit the config files directly.

## MCP Tools

### mcp__nixos__nix — Package/Option Lookup

- **Find a package**: `action: "search", query: "alacritty", source: "nixos", type: "packages"`
- **Package details**: `action: "info", query: "alacritty", source: "nixos", type: "packages"`
- **NixOS option**: `action: "search", query: "programs.niri", source: "nixos", type: "options"`
- **Home Manager option**: `action: "search", query: "programs.git", source: "home-manager", type: "options"`
- **Nix function (Noogle)**: `action: "search", query: "lib.mkIf", source: "noogle"`

### mcp__nixos__nix_versions — Version History

Check versions across channels: `package: "firefox"`. Filter: `package: "nodejs", version: "20"`.

## Build Commands

```bash
just switch    # rebuild and activate (.#my-machine)
just test      # activate without adding to boot menu
just check     # evaluate flake for errors
just update    # update all flake inputs
just gc        # garbage collect old generations
just diff      # show diff with nvd
```

Or use `nh os switch` which auto-detects the flake path.

## Common Pitfalls

- **Using `den` in inner modules** — `den` is a flake-parts arg, not available inside `nixos = { ... }:` blocks
- **Mixing module arguments** — `den`/`inputs` are outer; `config`/`pkgs`/`lib` are inner
- **Editing flake.nix** — almost never needed; import-tree auto-discovers
- **New files not visible** — nix flakes only see git-tracked files; stage new files with `git add`
- **The flake attribute is `.#my-machine`** — not `.#nixos` (old name)
- **Duplicate options** — if using `den.provides.user-shell`, don't also set `users.users.*.shell` in your aspect
- **Hardware files in modules/** — plain NixOS modules (not flake-parts) must live outside `modules/` (e.g., `hardware/`)
