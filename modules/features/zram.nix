{ self, inputs, ... }: {
  flake.nixosModules.zram = { lib, config, ... }: {
    options.features.zram.enable = lib.mkEnableOption "Zram compressed swap";

    config = lib.mkIf config.features.zram.enable {
      zramSwap.enable = true;
      zramSwap.algorithm = "zstd";
    };
  };
}
