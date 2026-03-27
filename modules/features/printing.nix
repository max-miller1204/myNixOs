{ self, inputs, ... }: {
  flake.nixosModules.printing = { pkgs, lib, config, ... }: {
    options.features.printing.enable = lib.mkEnableOption "Printing support";

    config = lib.mkIf config.features.printing.enable {
      services.printing.enable = true;
    };
  };
}
