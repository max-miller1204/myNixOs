---
name: nix
description: "Use this skill when the user asks about Nix, NixOS, flakes, flake-parts, nixpkgs, Home Manager, nix-darwin, system configuration, adding a machine or host, den, aspects, contexts, class routing, provides, homebrew, import-tree, NixOS options, NixOS packages, or mentions any .nix file. Also use when the user says 'search for a package', 'find a NixOS option', 'check package versions', 'how do I configure', 'add a service', 'add a package', 'what version of X', or asks about any system configuration task. Use this skill even for general Nix questions like 'what does mkIf do', 'how do overlays work', or 'explain derivations'. This skill provides NixOS domain expertise and integrates with mcp__nixos__nix and mcp__nixos__nix_versions MCP tools for real-time package and option lookups."
---

# Nix / NixOS Expert

Use the MCP tools below for real-time lookups — never guess package names, option paths, or versions. When working in `/home/max/myNixOS/`, follow the patterns here. For a detailed guide, read `docs/den.md`.

## Project Architecture

The config uses **flake-parts** + **import-tree** + **den** (aspect-oriented framework). Entry point is `flake.nix` → `inputs.import-tree ./modules` which auto-discovers all `.nix` files. You almost never edit `flake.nix` — just add files under `modules/`.

**Two module systems** coexist:
- **Outer** (flake-parts): `{ den, inputs, ... }: { ... }` — structures flake outputs and den config
- **Inner** (NixOS/HM): `{ config, pkgs, lib, ... }: { ... }` — configures the system

Never mix their arguments. `den`/`inputs` belong to the outer function; `config`/`pkgs`/`lib` belong to the inner.

## Hosts

Declared in `modules/hosts.nix`. Each gets an aspect in `modules/hosts/<name>.nix`.

| Host | System | Purpose |
|------|--------|---------|
| `nixos` | x86_64-linux | NixOS laptop (niri + noctalia desktop) |
| `my-macbook` | aarch64-darwin | Apple Silicon Mac |
| `ci-linux` | x86_64-linux | GitHub Actions runner (minimal, no users) |
| `ci-darwin` | aarch64-darwin | GitHub Actions runner (minimal, no users) |

## Class Keys

Aspects route config by class key:

| Key | Applied to |
|-----|-----------|
| `os` | Both NixOS and darwin (auto-forwarded) |
| `nixos` | NixOS hosts only |
| `darwin` | nix-darwin hosts only |
| `homeManager` | All users on all platforms |
| `hmLinux` | Home Manager on Linux only |
| `hmDarwin` | Home Manager on macOS only |

## Aspect Pattern

```nix
{ den, ... }: {
  den.aspects.my-feature = {
    os = { ... }: { };                 # both NixOS and darwin
    nixos = { pkgs, ... }: { };        # NixOS system config
    darwin = { pkgs, ... }: { };       # darwin system config
    homeManager = { ... }: { };        # HM on all platforms
    hmLinux = { ... }: { };            # HM Linux only
    hmDarwin = { ... }: { };           # HM macOS only
    includes = [ den.aspects.other ];  # compose aspects
  };
}
```

## Host → User Config (`provides.to-users`)

When a host aspect needs to push config to its users (e.g., deploy a config file), use `provides.to-users` — not a `homeManager` block in the host aspect:

```nix
den.aspects.niri = {
  nixos = { pkgs, ... }: { programs.niri.enable = true; };
  provides.to-users.homeManager = { ... }: {
    xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
  };
};
```

This scopes config to users on that specific host only.

## Package Placement

| Package type | Where | Example |
|---|---|---|
| User CLI tools | `homeManager.home.packages` | dev-tools.nix |
| User dotfiles/programs | `homeManager.programs.*` | git.nix, vim.nix |
| Linux-only user tools/config | `hmLinux` | codex, vscode, xdg.mimeApps, loupe |
| macOS-only user apps | `homebrew.casks` in homebrew.nix | claude, vscode, antigravity |
| System services/drivers | `nixos`/`darwin` blocks | audio.nix, nvidia.nix |
| Cross-platform system config | `os` block | nix-settings.nix |
| Overlay-dependent packages | `nixos.environment.systemPackages` | overlays.nix (tied to system overlay) |

## Den Provides

Infrastructure in `defaults.nix` and user includes:

- `den.provides.define-user` — user creation infrastructure
- `den.provides.hostname` — sets hostname from den host name
- `den.provides.inputs'` — per-system flake inputs (`inputs'` arg)
- `den.provides.self'` — per-system self outputs
- `den.provides.primary-user` — admin user (wheel group)
- `(den.provides.user-shell "fish")` — login shell on all platforms
- `den._.mutual-provider` — host↔user bidirectional config

User creation is handled by den provides — don't manually declare `users.users.*` in host aspects.

## Key Files

| File | Purpose |
|---|---|
| `modules/den.nix` | Den bootstrap + darwinConfigurations option |
| `modules/defaults.nix` | State versions + den.provides infrastructure (no aspects here) |
| `modules/schema.nix` | hmLinux/hmDarwin class forwarding |
| `modules/hosts.nix` | All host/user declarations |
| `modules/hosts/nixos.nix` | NixOS host aspect |
| `modules/hosts/my-macbook.nix` | Darwin host aspect |
| `modules/hosts/ci-linux.nix` | CI host (minimal, self-contained) |
| `modules/hosts/ci-darwin.nix` | CI host (minimal, self-contained) |
| `modules/aspects/max.nix` | User aspect (includes all user features) |
| `modules/aspects/*.nix` | Feature aspects |
| `hardware/my-machine.nix` | Hardware config (outside modules/) |
| `.github/workflows/build.yaml` | CI pipeline |
| `docs/den.md` | Detailed guide — read for how-tos |

## Adding Things

**New package**: Add to an existing aspect's `homeManager.home.packages` (or `hmLinux` if Linux-only, or `homebrew.casks` if macOS-only).

**New aspect**: Create `modules/aspects/foo.nix`, add `den.aspects.foo` to the appropriate host or user `includes`.

**New machine**: Add to `modules/hosts.nix`, create `modules/hosts/<name>.nix`, create `hardware/<name>.nix`.

**New Homebrew cask**: Add to `modules/aspects/homebrew.nix` `casks` list.

## Niri and Noctalia

Native config files deployed via `provides.to-users`:
- **Niri**: `modules/aspects/niri/config.kdl` (KDL)
- **Noctalia**: `modules/aspects/noctalia/settings.json` (JSON)

Edit these files directly to change keybinds/settings.

## MCP Tools

### mcp__nixos__nix — Package/Option Lookup

- **Find a package**: `action: "search", query: "alacritty", source: "nixos", type: "packages"`
- **Package details**: `action: "info", query: "alacritty", source: "nixos", type: "packages"`
- **NixOS option**: `action: "search", query: "programs.niri", source: "nixos", type: "options"`
- **Home Manager option**: `action: "search", query: "programs.git", source: "home-manager", type: "options"`
- **Nix function**: `action: "search", query: "lib.mkIf", source: "noogle"`

### mcp__nixos__nix_versions — Version History

Check versions: `package: "firefox"`. Filter: `package: "nodejs", version: "20"`.

## Build Commands

```bash
just switch    # rebuild and activate (.#nixos)
just test      # test without persisting
just check     # validate flake
just update    # update all inputs
just gc        # garbage collect
just diff      # show changes with nvd
```

## Common Pitfalls

- **`den` in inner modules** — `den` is a flake-parts arg, not available inside `nixos = { ... }:` blocks
- **`homeManager` in host aspects** — use `provides.to-users.homeManager` for host→user config
- **`users.users.*` in host aspects** — den provides handle user creation; don't declare users manually
- **User packages in `environment.systemPackages`** — use `homeManager.home.packages` (exception: overlay-dependent packages stay at system level)
- **Linux-only HM config in `homeManager`** — use `hmLinux` (e.g., `xdg.mimeApps`, GTK/Qt, loupe/zathura)
- **Linux-only packages in `homeManager`** — packages like `loupe` that have Linux-only deps must go in `hmLinux`, not `homeManager`
- **Aspects in `defaults.nix`** — defaults should only contain `den.provides.*` infrastructure, not aspects
- **New files not visible** — nix flakes only see git-tracked files; `git add` first
- **Hardware files** — must live outside `modules/` (e.g., `hardware/`) since import-tree loads everything as flake-parts modules
- **`darwinConfigurations` option** — defined in `den.nix` because flake-parts doesn't provide it
