{ self, inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.antigravity-nix.overlays.default
        inputs.codex-cli-nix.overlays.default
        inputs.copilot-cli-nix.overlays.default
        inputs.oh-my-codex-nix.overlays.default
        inputs.oh-my-openagent-nix.overlays.default
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        antigravity
        codex
        github-copilot-cli
        opencode
        oh-my-codex
        oh-my-openagent
      ];
    };
  };
}
