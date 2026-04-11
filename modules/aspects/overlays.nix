{ inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.codex-cli-nix.overlays.default
        inputs.stt-nix.overlays.default
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        codex
      ];
    };
  };
}
