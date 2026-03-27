{ self, inputs, ... }: {
  flake.nixosModules.utilities = { pkgs, lib, config, ... }: {
    options.features.utilities.enable = lib.mkEnableOption "Miscellaneous utilities";

    config = lib.mkIf config.features.utilities.enable {
      environment.systemPackages = with pkgs; [
        anki
        nvd
        pfetch-rs
        bubblewrap
      ];
    };
  };
}
