{ self, inputs, ... }: {
  flake.nixosModules.greetd = { pkgs, lib, config, ... }: {
    options.features.greetd.enable = lib.mkEnableOption "greetd display manager with regreet";

    config = lib.mkIf config.features.greetd.enable {
      programs.regreet = {
        enable = true;
        settings.default_session.command = "niri-session";
      };
    };
  };
}
