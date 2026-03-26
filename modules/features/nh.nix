{ self, inputs, ... }: {
  flake.nixosModules.nh = { lib, config, ... }: {
    options.features.nh.enable = lib.mkEnableOption "nh Nix helper CLI";

    config = lib.mkIf config.features.nh.enable {
      programs.nh = {
        enable = true;
        flake = "/home/${config.my.variables.username}/myNixOS";
      };
    };
  };
}
