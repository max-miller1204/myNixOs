{ self, inputs, ... }: {
  flake.nixosModules.greetd = { pkgs, lib, config, ... }: {
    options.features.greetd.enable = lib.mkEnableOption "greetd display manager with tuigreet";

    config = lib.mkIf config.features.greetd.enable {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };
  };
}
