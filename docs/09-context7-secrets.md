# Recipe: Managing Secrets with sops-nix

This repo uses [sops-nix](https://github.com/Mic92/sops-nix) at the **Home Manager
level** to store encrypted secrets in git and decrypt them at login.

## How it works

```
secrets/*.sops.yaml (encrypted, committed to git)
  → sops-nix HM module decrypts on login using AGE private key
  → ~/.config/sops-nix/secrets/<secret_name> (plaintext, only at runtime)
```

The AGE private key lives at `~/.config/sops/age/keys.txt` and is the one
piece that must be transferred manually to new machines.

Secrets are declared inside `modules/features/home.nix` in the Home Manager
user block, not at the system level.

## Prerequisites: `.sops.yaml` config

sops needs to know which encryption keys to use:

```yaml
# .sops.yaml
keys:
  - &max age15ru6t...your_public_key

creation_rules:
  - path_regex: secrets/.*\.sops\.yaml$
    key_groups:
      - age:
          - *max
```

Get your public key with:
```bash
nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
```

## Adding a new secret

### 1. Add the secret to a sops file

```bash
nix shell nixpkgs#sops nixpkgs#age --command sops secrets/my-service.sops.yaml
```

Or with the justfile:

```bash
just edit-secret my-service
```

This opens your editor — add key/value pairs and save. sops encrypts automatically.

### 2. Declare the secret in home.nix

Add the secret declaration inside the Home Manager user block in
`modules/features/home.nix`:

```nix
home-manager.users.${config.my.variables.username} = { config, ... }: {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets.my_api_key = {
    sopsFile = ../../secrets/my-service.sops.yaml;
  };

  # Use it in a wrapper script:
  home.file.".claude/run-my-service.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      export MY_API_KEY="$(tr -d '\n' < "${config.sops.secrets.my_api_key.path}")"
      exec my-service "$@"
    '';
  };
};
```

### 3. Rebuild

```bash
just switch
```

The secret is decrypted when you log in. Access it via `config.sops.secrets.my_api_key.path`
in Nix, or read the file directly from a script.

## Worked examples

### Context7

| Piece | File |
|---|---|
| Encrypted secret | `secrets/context7.sops.yaml` |
| HM SOPS declaration | `modules/features/home.nix` (inside HM user block) |
| Wrapper script | `~/.claude/run-context7.sh` (reads `config.sops.secrets.context7_api_key.path`) |
| MCP server entry | Declared in `claudeMcpServers` attrset in `modules/features/home.nix` |

### YouTube MCP Server

| Piece | File / Source |
|---|---|
| Nix derivation | External flake: `github:max-miller1204/youtube-mcp-server-nix` |
| Encrypted secret | `secrets/youtube.sops.yaml` |
| HM SOPS declaration | `modules/features/home.nix` (inside HM user block) |
| Wrapper script | `~/.claude/run-youtube.sh` (reads `config.sops.secrets.youtube_api_key.path`) |
| MCP server entry | Declared in `claudeMcpServers` attrset in `modules/features/home.nix` |

## HM vs system-level SOPS

Previously, secrets were managed at the system level with separate NixOS modules
(`context7-secret.nix`, `youtube-secret.nix`) that decrypted to `/run/secrets/`.
These were migrated to the Home Manager level because:

- MCP server secrets are user-specific, not system-wide
- HM SOPS decrypts at login, which is fine since Claude Code only runs in user sessions
- Simpler: all secret config lives in one file (`home.nix`) instead of scattered modules

## Bootstrap on a new machine

1. Create a local AGE key:

```bash
mkdir -p ~/.config/sops/age
nix shell nixpkgs#age --command age-keygen -o ~/.config/sops/age/keys.txt
```

2. Get the new public key:

```bash
nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
```

3. Re-encrypt existing secrets with the new key:

```bash
just rekey
```

Or if transferring from an existing machine, just copy `~/.config/sops/age/keys.txt`
and rebuild — no re-encryption needed.

4. Rebuild:

```bash
just switch
```

## Tips

- **One sops file per service** keeps things modular
- **Never commit plaintext keys** — if you accidentally do, rotate immediately
- **`just edit-secret <name>`** to quickly edit a secret file
- **`just rekey`** to re-encrypt all secrets after key changes
