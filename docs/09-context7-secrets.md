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

## Adding a new secret

### 1. Add the secret to a sops file

Add to an existing file:

```bash
nix shell nixpkgs#sops nixpkgs#age --command sops secrets/context7.sops.yaml
```

This opens your editor — add a new key/value pair and save.

Or create a new sops file:

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
{ inputs, lib, ... }:
let
  secretFile = ../../secrets/my-service.sops.yaml;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  flake.nixosModules.myServiceSecret = { ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      age.keyFile = "/home/max/.config/sops/age/keys.txt";
      age.generateKey = false;
    } // lib.optionalAttrs hasSecretFile {
      defaultSopsFile = secretFile;
      defaultSopsFormat = "yaml";
      secrets.my_api_key = {
        mode = "0400";
        owner = "max";
      };
    };
  };
}
```

### 3. Import the module in your machine config

```nix
# modules/hosts/my-machine/configuration.nix
imports = [
  self.nixosModules.myServiceSecret
  # ...
];
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

## Worked example: Context7

The Context7 MCP server is the existing example of this pattern:

| Piece | File |
|---|---|
| Encrypted secret | `secrets/context7.sops.yaml` |
| Nix module | `modules/features/context7-secret.nix` |
| Wrapper script | `~/.claude/run-context7.sh` (reads `/run/secrets/context7_api_key`) |
| MCP server entry | Declared in `claudeMcpServers` attrset in `modules/features/home.nix` |

The wrapper script reads the decrypted key at runtime — no plaintext key
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
