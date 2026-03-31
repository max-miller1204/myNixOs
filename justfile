# System management commands (auto-detects platform)

# Rebuild and switch to new configuration
switch:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        darwin-rebuild switch --flake .#my-macbook
    else
        sudo nixos-rebuild switch --flake .#nixos
    fi

# Rebuild and set as next boot configuration (NixOS only)
boot:
    sudo nixos-rebuild boot --flake .#nixos

# Rebuild and activate without adding to boot menu
test:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        darwin-rebuild check --flake .#my-macbook
    else
        sudo nixos-rebuild test --flake .#nixos
    fi

# Update all flake inputs
update:
    nix flake update

# Run garbage collection
gc:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        nix-collect-garbage -d
    else
        sudo nix-collect-garbage -d
    fi

# Check flake for errors
check:
    nix flake check

# Show diff between current system and new build
diff:
    #!/usr/bin/env bash
    if [[ "$(uname)" == "Darwin" ]]; then
        darwin-rebuild build --flake .#my-macbook
    else
        nixos-rebuild build --flake .#nixos && nvd diff /run/current-system result
    fi

# Re-encrypt all secrets after key changes
rekey:
    sops updatekeys secrets/*.sops.yaml

# Edit a specific secret file
edit-secret NAME:
    sops secrets/{{NAME}}.sops.yaml

# Stage, commit, and push all changes
push MESSAGE="update":
    git add -A && git commit -m "{{MESSAGE}}" && git push
