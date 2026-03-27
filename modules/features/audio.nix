{ self, inputs, ... }: {
  flake.nixosModules.audio = { pkgs, lib, config, ... }: {
    options.features.audio.enable = lib.mkEnableOption "PipeWire audio stack";

    config = lib.mkIf config.features.audio.enable {
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      environment.systemPackages = with pkgs; [
        sox
      ];
    };
  };
}
