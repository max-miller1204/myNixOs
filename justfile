# NixOS system management commands

# Rebuild and switch to new configuration
switch:
    sudo nixos-rebuild switch --flake .#my-machine

# Rebuild and set as next boot configuration
boot:
    sudo nixos-rebuild boot --flake .#my-machine

# Rebuild and activate without adding to boot menu
test:
    sudo nixos-rebuild test --flake .#my-machine

# Update all flake inputs
update:
    nix flake update

# Run garbage collection
gc:
    sudo nix-collect-garbage -d

# Check flake for errors
check:
    nix flake check

# Show diff between current system and new build
diff:
    nixos-rebuild build --flake .#my-machine && nvd diff /run/current-system result

# Re-encrypt all secrets after key changes
rekey:
    sops updatekeys secrets/*.sops.yaml

# Edit a specific secret file
edit-secret NAME:
    sops secrets/{{NAME}}.sops.yaml

# Stage, commit, and push all changes
push MESSAGE="update":
    git add -A && git commit -m "{{MESSAGE}}" && git push
