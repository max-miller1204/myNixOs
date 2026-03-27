{ self, inputs, ... }: {
  flake.nixosModules.bluetooth = { pkgs, lib, config, ... }: {
    options.features.bluetooth.enable = lib.mkEnableOption "Bluetooth support";

    config = lib.mkIf config.features.bluetooth.enable {
      hardware.bluetooth.enable = true;
    };
  };
}
