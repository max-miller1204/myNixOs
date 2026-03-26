# Recipe: Managing Secrets with sops-nix

This repo uses [sops-nix](https://github.com/Mic92/sops-nix) to store encrypted
secrets in git and decrypt them at `/run/secrets/` on rebuild. This works for
any secret — API keys, tokens, database passwords, service credentials, etc.

## How it works

```
secrets/*.sops.yaml (encrypted, committed to git)
  → sops-nix decrypts on rebuild using AGE private key
  → /run/secrets/<secret_name> (plaintext, only at runtime, never in Nix store)
```

The AGE private key lives at `~/.config/sops/age/keys.txt` and is the one
piece that must be transferred manually to new machines.

## Prerequisites: `.sops.yaml` config

sops needs to know which encryption keys to use. There are two ways:

1. **`.sops.yaml` config file (recommended)** — lives at the project root and
   tells sops which AGE keys to use automatically. This lets you run simple
   commands like `sops secrets/foo.sops.yaml` to create/edit secrets.

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

2. **`--age` flag on the command line** — passes the key inline, bypassing
   `.sops.yaml` entirely. This works but is verbose and easy to forget.

If you have `.sops.yaml` set up, use the simpler commands below. If not,
you'll need to pass `--age` explicitly every time.

## Adding a new secret

### 1. Add the secret to a sops file

**With `.sops.yaml` (simple):**

```bash
nix shell nixpkgs#sops nixpkgs#age --command sops secrets/my-service.sops.yaml
```

This opens your editor — add key/value pairs and save. sops encrypts automatically.

**Without `.sops.yaml` (inline key):**

```bash
nix shell nixpkgs#sops nixpkgs#age --command \
  sops --encrypt \
  --age "$(nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt)" \
  --input-type dotenv \
  --output-type yaml \
  <(printf 'my_api_key=%s\n' 'sk-your-key-here') \
  > secrets/my-service.sops.yaml
```

### 2. Declare the secret in a Nix module

Create a new module or add to an existing one:

```nix
# modules/features/my-service-secret.nix
{ lib, ... }:
let
  secretFile = ../../secrets/my-service.sops.yaml;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  flake.nixosModules.myServiceSecret = { config, ... }: {
    options.features.myServiceSecret.enable = lib.mkEnableOption "My Service SOPS secret";

    config = lib.mkIf config.features.myServiceSecret.enable {
      sops = lib.optionalAttrs hasSecretFile {
        secrets.my_api_key = {
          sopsFile = secretFile;
          format = "yaml";
          mode = "0400";
          owner = "max";
        };
      };

      warnings = lib.optionals (!hasSecretFile) [
        "my-service secret file is missing: secrets/my-service.sops.yaml"
      ];
    };
  };
}
```

**Note:** sops-nix and the base age key config are imported once in
`configuration.nix`, so secret modules only need to declare their secrets.
Use the per-secret `sopsFile` attribute to point at the correct encrypted file.

### 3. Import and enable the module in your machine config

```nix
# modules/hosts/my-machine/configuration.nix
imports = [
  self.nixosModules.myServiceSecret
  # ...
];

features.myServiceSecret.enable = true;
```

### 4. Rebuild

```bash
sudo nixos-rebuild switch --flake .#myMachine
```

The secret is now at `/run/secrets/my_api_key`.

### 5. Use it

From a script:

```bash
export MY_API_KEY="$(cat /run/secrets/my_api_key)"
```

From a systemd service (in NixOS config):

```nix
systemd.services.my-service = {
  serviceConfig.EnvironmentFile = "/run/secrets/my_api_key";
};
```

## Worked examples

### Context7

| Piece | File |
|---|---|
| Encrypted secret | `secrets/context7.sops.yaml` |
| Nix module | `modules/features/context7-secret.nix` |
| Wrapper script | `~/.claude/run-context7.sh` (reads `/run/secrets/context7_api_key`) |
| MCP server entry | Declared in `claudeMcpServers` attrset in `modules/features/home.nix` |

### YouTube MCP Server

| Piece | File / Source |
|---|---|
| Nix derivation | External flake: `github:max-miller1204/youtube-mcp-server-nix` |
| Encrypted secret | `secrets/youtube.sops.yaml` |
| Nix module | `modules/features/youtube-secret.nix` |
| Wrapper script | `~/.claude/run-youtube.sh` (reads `/run/secrets/youtube_api_key`) |
| MCP server entry | Declared in `claudeMcpServers` attrset in `modules/features/home.nix` |

The upstream npm package was broken, so the server is built from source in a
separate flake repo and added as a flake input in `flake.nix`.

**Note:** Both secret modules use per-secret `sopsFile` to point at their own
encrypted file. The base sops-nix import and age key config live in
`configuration.nix`, so secret modules only declare their secrets:

```nix
secrets.youtube_api_key = {
  sopsFile = secretFile;   # points to this module's encrypted file
  format = "yaml";
  mode = "0400";
  owner = "max";
};
```

Use this per-secret `sopsFile` pattern for all secrets.

Each wrapper script reads the decrypted key at runtime — no plaintext key
ever touches a config file.

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

3. Re-encrypt existing secrets with the new key (add the public key to each
   sops file's AGE recipients):

```bash
nix shell nixpkgs#sops nixpkgs#age --command \
  sops updatekeys secrets/context7.sops.yaml
```

Or if transferring from an existing machine, just copy `~/.config/sops/age/keys.txt`
(back it up in a password manager, USB key, etc.) and rebuild — no re-encryption needed.

4. Rebuild:

```bash
sudo nixos-rebuild switch --flake .#myMachine
```

## Tips

- **One sops file per service** keeps things modular and lets you grant
  different permissions per secret
- **Multiple keys in one file** is fine too if they're related (e.g., a
  service's key + secret pair)
- **Never commit plaintext keys** — if you accidentally do, rotate the key
  immediately (git history preserves it)
- **`builtins.pathExists`** guard (as in `context7-secret.nix`) lets the
  config evaluate even when the secret file doesn't exist yet — useful for
  bootstrapping
