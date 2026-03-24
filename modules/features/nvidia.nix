{ ... }: {
  flake.nixosModules.nvidia = { lib, config, ... }: {
    options.features.nvidia.enable = lib.mkEnableOption "NVIDIA drivers";

    config = lib.mkIf config.features.nvidia.enable {
      hardware.graphics.enable = true;

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
      };
    };
  };
}
