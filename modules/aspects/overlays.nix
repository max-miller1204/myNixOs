{ self, inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.antigravity-nix.overlays.default
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        antigravity
      ];
    };
  };
}
