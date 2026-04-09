{ inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.code-cursor-nix.overlays.default
        inputs.codex-cli-nix.overlays.default
        inputs.copilot-cli-nix.overlays.default
        inputs.opencode-nix.overlays.default
        inputs.stt-nix.overlays.default
        inputs.noctalia-qs.overlays.default
        (final: prev: { noctalia-qs = final.quickshell; })
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        cursor
        codex
        github-copilot-cli
        opencode
      ];
    };
  };
}
