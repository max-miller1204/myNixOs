# Recipe: Adding an MCP Server to Claude Code

Claude Code uses MCP (Model Context Protocol) servers to extend its capabilities
(e.g., documentation lookup, NixOS package search).

## How MCP servers are managed

MCP servers are declared in `modules/features/home.nix` as a Nix attrset and
merged into `~/.claude.json` on every `nixos-rebuild switch` via a Home Manager
activation script. This makes them fully reproducible across machines.

```
home.nix (Nix attrset)
  → ~/.config/claude-code/mcp-servers.json (Nix store, read-only)
  → activation script merges into ~/.claude.json (preserves runtime state)
```

## Adding an MCP server

Edit the `claudeMcpServers` attrset in `modules/features/home.nix`:

```nix
claudeMcpServers = {
  nixos = {
    command = "nix";
    args = [ "run" "github:utensils/mcp-nixos" "--" ];
    type = "stdio";
  };
  context7 = {
    command = "${config.home.homeDirectory}/.claude/run-context7.sh";
    args = [ ];
    type = "stdio";
  };
  # Add new servers here:
  my-server = {
    command = "nix";
    args = [ "run" "github:author/mcp-server" "--" ];
    type = "stdio";
  };
};
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#myMachine
```

Restart Claude Code and verify with `/mcp`.

## NixOS considerations

Most MCP servers expect `npx` or `node` in `$PATH`, which NixOS doesn't
provide by default. Two approaches:

### 1. Use `nix run` directly (preferred for flake-based servers)

```nix
my-server = {
  command = "nix";
  args = [ "run" "github:author/mcp-server" "--" ];
  type = "stdio";
};
```

### 2. Use a wrapper script (for npm-based servers)

Add a wrapper in `home.nix` via `home.file`:

```nix
home.file.".claude/run-my-server.sh" = {
  executable = true;
  text = ''
    #!/usr/bin/env bash
    exec nix shell nixpkgs#nodejs --command npx -y @some/mcp-server "$@"
  '';
};
```

Then reference it in the `claudeMcpServers` attrset:

```nix
my-server = {
  command = "${config.home.homeDirectory}/.claude/run-my-server.sh";
  args = [ ];
  type = "stdio";
};
```

## API keys and secrets

Never put API keys in the MCP server definitions. Instead, use a wrapper
script that reads from sops-nix secrets at runtime. See `docs/09-context7-secrets.md`
for the full pattern (Context7 is the working example).

### Transferring to a new machine

The AGE private key at `~/.config/sops/age/keys.txt` is the one piece that
can't live in your Nix config (it's what decrypts everything else). To set up
a new machine:

1. Copy `~/.config/sops/age/keys.txt` from your current machine (back it up
   in a password manager, USB key, etc.)
2. Place it at the same path on the new machine (`chmod 600`)
3. Rebuild — sops-nix will decrypt your secrets automatically

If you lose the key, generate a new one on the new machine and re-encrypt
your secrets with the new public key:

```bash
# Generate new key
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

# Get the new public key
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt

# Update .sops.yaml with the new public key, then re-encrypt
sops updatekeys secrets/context7.sops.yaml
```

## nix-darwin compatibility

The Home Manager parts (MCP server definitions, activation script, wrapper
scripts) work on nix-darwin with minimal changes:

- **Home directory**: The Nix config uses `config.home.homeDirectory` which
  resolves to `/Users/max` on macOS instead of `/home/max` — handled
  automatically
- **`nix shell`/`nix run`**: Work identically on macOS
- **sops-nix**: Supports nix-darwin via `inputs.sops-nix.darwinModules.sops`.
  Decrypted secrets go to `/run/secrets/` on both platforms, so
  `run-context7.sh` works as-is
- **AGE key location**: macOS convention is
  `~/Library/Application Support/sops/age/keys.txt`, but since
  `context7-secret.nix` explicitly sets `age.keyFile` you can use any path

To port this config to darwin, you'd need to:

1. Replace `inputs.sops-nix.nixosModules.sops` with `inputs.sops-nix.darwinModules.sops`
2. Update the `age.keyFile` path in `context7-secret.nix` to the darwin user's home

## How the activation script works

On every rebuild, the activation script:

1. Reads `~/.config/claude-code/mcp-servers.json` (Nix-generated, contains only `mcpServers`)
2. Merges it into `~/.claude.json` using `jq -s '.[0] * .[1]'`
3. Preserves all other runtime state (session metrics, auth, tips, etc.)

If `~/.claude.json` doesn't exist yet (first boot), it creates it with just the MCP servers.
Claude Code will populate the rest on first launch.

**Note:** Nix is the single source of truth. Any MCP server added manually to
`~/.claude.json` will be overwritten on the next rebuild.
