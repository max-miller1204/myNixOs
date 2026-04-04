# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-04
**Commit:** 24dd3b3
**Branch:** main

## OVERVIEW

NixOS + nix-darwin personal config using flake-parts, import-tree, and den (aspect-oriented framework). Manages one Linux laptop (`nixos`), one MacBook (`my-macbook`), and two CI-only hosts.

## STRUCTURE

```
.
├── flake.nix              # Entry point — mkFlake + import-tree ./modules
├── justfile               # Task runner: switch, test, check, update, gc, diff, rekey, push
├── .sops.yaml             # Age-based secret encryption config
├── modules/
│   ├── den.nix            # Imports den.flakeModule + darwinConfigurations option shim
│   ├── schema.nix         # hmLinux/hmDarwin → homeManager class forwarding
│   ├── defaults.nix       # State versions + den.provides infrastructure ONLY
│   ├── hosts.nix          # Host/user registry (4 hosts, 1 user)
│   ├── parts.nix          # Supported systems list
│   ├── hosts/             # Per-machine aspect compositions
│   └── aspects/           # Reusable feature modules (29 .nix + assets)
├── hardware/
│   └── my-machine.nix     # Hardware scan (plain NixOS module, outside import-tree)
├── secrets/               # sops-encrypted YAML files
└── docs/
    └── den.md             # Project handbook (306 lines)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add a user package | `modules/aspects/<feature>.nix` → `homeManager.home.packages` | Cross-platform |
| Add Linux-only user pkg | Same file → `hmLinux.home.packages` | Never use `mkIf isLinux` |
| Add macOS app | `modules/aspects/homebrew.nix` → `casks` | Declarative Homebrew |
| Add system service | `modules/aspects/<feature>.nix` → `nixos`/`darwin` block | Or `os` for both |
| Add new aspect | Create `modules/aspects/<name>.nix`, include in host or user aspect | import-tree auto-discovers |
| Add new machine | `modules/hosts.nix` + `modules/hosts/<name>.nix` + `hardware/<name>.nix` | See docs/den.md |
| Deploy host→user config | `provides.to-users.homeManager` in the aspect | Not host `homeManager` block |
| Edit secrets | `just edit-secret <name>` | sops + age |
| Understand den framework | `docs/den.md` | Authoritative reference |

## CONVENTIONS

- **Never edit `flake.nix`** to add modules — import-tree auto-loads everything under `modules/`.
- **Platform routing** via class keys: `os`, `nixos`, `darwin`, `homeManager`, `hmLinux`, `hmDarwin`. Never use manual `mkIf pkgs.stdenv.isLinux`.
- **`defaults.nix`** is infrastructure only — state versions + `den.provides.*`. No aspects or feature config.
- **User creation** handled by `den.provides.define-user` / `primary-user`. Never manually set `users.users.*`.
- **Host→user file deployment** uses `provides.to-users`, not host-level `homeManager` blocks.
- **Den names = identity**: host name in `den.hosts` becomes hostname, flake attr, and aspect name.
- **No formatter/linter configured** — no treefmt, nixfmt, alejandra, statix, or deadnix.
- **No explicit `checks` flake output** — validation is "build the config" via CI.
- **Fish** is the default shell (`den.provides.user-shell "fish"`).
- **Catppuccin mocha/mauve** is the standard theme.
- **State versions**: NixOS/HM = `25.11`, darwin = `6`.

## ANTI-PATTERNS (THIS PROJECT)

- `mkIf pkgs.stdenv.isLinux` — use `hmLinux`/`nixos` class keys instead
- `mkIf pkgs.stdenv.isDarwin` — use `hmDarwin`/`darwin` class keys instead
- `mkEnableOption` / `mkIf config.*.enable` — den aspects replace this pattern
- Putting feature config in `defaults.nix`
- Manual `users.users.*` declarations
- Editing `flake.nix` to add modules
- Host-level `homeManager` blocks for host→user config (use `provides.to-users`)

## COMMANDS

```bash
just switch    # Rebuild + activate (OS-aware: nixos-rebuild or darwin-rebuild)
just test      # Validate without persisting
just check     # nix flake check
just update    # nix flake update
just diff      # Build + nvd diff (Linux only)
just gc        # Garbage collect (sudo on Linux)
just rekey     # Re-encrypt secrets after key changes
just edit-secret NAME  # Edit a sops secret
just push MESSAGE      # git add -A && commit && push
```

## NOTES

- `hardware/my-machine.nix` lives outside `modules/` intentionally — it's a plain NixOS module not managed by den/import-tree.
- CI hosts (`ci-linux`, `ci-darwin`) are minimal stubs for build validation only.
- `modules/aspects/` contains non-Nix assets (`.kdl`, `.json`, `.sh`, `.png`) alongside `.nix` files — these are deployed via `xdg.configFile` or `home.file`.
- `modules/den.nix` exists solely to shim `flake.darwinConfigurations` option that flake-parts doesn't define.
- `modules/schema.nix` implements `den._.forward` to route `hmLinux`/`hmDarwin` into `homeManager` with platform guards — this is the magic that makes platform-specific HM config work without `mkIf`.
- No `README.md` — `docs/den.md` is the project handbook.
