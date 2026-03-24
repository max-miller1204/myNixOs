# Vimjoyer Video Reference

Curated Nix videos from [Vimjoyer's YouTube channel](https://www.youtube.com/@vimjoyer) relevant to this config stack. Full transcripts and summaries are in `~/youtube-scrapes/Vimjoyer/`.

---

## Flake-Parts & Dendritic Pattern

These explain the core architecture this config uses.

| Video | Key Topics |
|---|---|
| [Best Modular Nix Flake Framework (flake-parts)](https://www.youtube.com/watch?v=kvprcW6QMIE) | `perSystem`, `self'`, `flake` vs `perSystem`, options/merging — see [01-flake-parts.md](01-flake-parts.md), [05-per-system.md](05-per-system.md) |
| [Elevate Your Nix Config With Dendritic Pattern](https://www.youtube.com/watch?v=-TRbzkw6Hjs) | import-tree, every file as flake-parts module, no glue code — see [02-import-tree.md](02-import-tree.md) |
| [Ultimate NixOS Desktop: Niri, Noctalia, Dendritic Pattern](https://www.youtube.com/watch?v=aNgujRXDTdE) | Full setup walkthrough matching this repo's stack exactly — see [06-wrapper-modules.md](06-wrapper-modules.md), [07-adding-a-machine.md](07-adding-a-machine.md), [08-adding-a-feature.md](08-adding-a-feature.md) |

## Wrapper-Modules & Dotfiles

How this config wraps niri and noctalia into portable packages.

| Video | Key Topics |
|---|---|
| [Homeless Dotfiles With Nix Wrappers](https://www.youtube.com/watch?v=Zzvn9uYjQJY) | `symlinkJoin`, `wrapProgram`, wrapper-modules by Lassilus, `wrapModule` — see [06-wrapper-modules.md](06-wrapper-modules.md) |

## Secrets Management

How this config handles API keys and tokens.

| Video | Key Topics |
|---|---|
| [NixOS Secrets Management (SOPS-NIX)](https://www.youtube.com/watch?v=G5f6GC7SnhU) | age keys, `.sops.yaml`, sops-nix module, `/run/secrets/`, runtime-only access — see [09-context7-secrets.md](09-context7-secrets.md) |

## NixOS Module System

Understanding the options/config pattern used everywhere in this config.

| Video | Key Topics |
|---|---|
| [Modularize NixOS and Home Manager](https://www.youtube.com/watch?v=vYc6IzKvAJQ) | `mkEnableOption`, `mkIf`, `mkDefault`, `mkForce`, toggleable modules, multi-host structure — see [04-nixos-modules.md](04-nixos-modules.md) |
| [Custom NIX Home-Manager Modules](https://www.youtube.com/watch?v=EUiXzX7nthY) | Custom options/config, submodules, `builtins.map`, per-host differences |

## Nix Language Fundamentals

Foundation knowledge for reading and writing Nix code.

| Video | Key Topics |
|---|---|
| [Nix Functions Explained](https://www.youtube.com/watch?v=HiTgbsFlPzs) | Lambdas, currying, destructured sets, `@` syntax, builtins, Noogle |
| [Nix is Simpler Than You Think (Derivations & Packages)](https://www.youtube.com/watch?v=GBTTVrmqkfE) | Derivations, Nix store, binary cache, `mkDerivation`, `fetchFromGitHub` |
| [Customize Nix Packages (Overrides & Overlays)](https://www.youtube.com/watch?v=jHb7Pe7x1ZY) | `.override`, `.overrideAttrs`, overlays (final/prev) |

## Debugging

| Video | Key Topics |
|---|---|
| [Stop Guessing: Debug Nix Code (Nix REPL)](https://www.youtube.com/watch?v=swiWnAwionc) | `:lf`, `:p`, `:doc`, `:e`, `nixos-rebuild repl`, nix-inspect |
| [6 Popular NixOS Beginner Mistakes](https://www.youtube.com/watch?v=jQzPRYgJw04) | Common pitfalls: state version, channels vs flakes, unstable packages |
