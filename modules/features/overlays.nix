{ self, inputs, ... }: {
  flake.nixosModules.overlays = { pkgs, lib, config, ... }: {
    options.features.overlays.enable = lib.mkEnableOption "Package overlays";

    config = lib.mkIf config.features.overlays.enable {
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
