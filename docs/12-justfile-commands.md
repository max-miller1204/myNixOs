# Justfile Commands

The `justfile` at the repo root provides shortcuts for common operations.
Run them with `just <command>` from the repo directory.

## System management

| Command | What it does |
|---|---|
| `just switch` | `sudo nixos-rebuild switch --flake .#nixos` — rebuild and activate |
| `just boot` | `sudo nixos-rebuild boot --flake .#nixos` — rebuild, activate on next boot |
| `just test` | `sudo nixos-rebuild test --flake .#nixos` — rebuild and activate without adding to boot menu |
| `just update` | `nix flake update` — update all flake inputs to latest |
| `just gc` | `sudo nix-collect-garbage -d` — delete old generations and free disk space |
| `just check` | `nix flake check` — evaluate flake for syntax/type errors without building |
| `just diff` | Build new config and show diff against current system (uses `nvd`) |

## Secrets management

| Command | What it does |
|---|---|
| `just rekey` | Re-encrypt all secrets after AGE key changes |
| `just edit-secret <NAME>` | Open `secrets/<NAME>.sops.yaml` in your editor for editing |

## Git workflow

| Command | What it does |
|---|---|
| `just push` | Stage all, commit with "update" message, and push |
| `just push "my message"` | Stage all, commit with custom message, and push |

## Using nh instead

`nh` is also available as an alternative to `just switch`:

```bash
nh os switch      # equivalent to just switch, with colored diff
nh os boot        # equivalent to just boot
```

`nh` automatically knows the flake path (`/home/max/myNixOS`) from its config.

## Prerequisites

- `just` and `nvd` are installed as system packages
- `sops` is available via `nix shell nixpkgs#sops` (used by `just rekey` and `just edit-secret`)
