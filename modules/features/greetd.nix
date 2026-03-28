{ self, inputs, ... }: {
  flake.nixosModules.greetd = { pkgs, lib, config, ... }: {
    options.features.greetd.enable = lib.mkEnableOption "greetd display manager with regreet";

    config = lib.mkIf config.features.greetd.enable {
      environment.etc."greetd/wallpaper".source = config.my.variables.wallpaper;

      programs.regreet = {
        enable = true;
        cageArgs = [ "-m" "last" ];
        settings = {
          default_session.command = "niri-session";
          background = {
            path = "/etc/greetd/wallpaper";
            fit = "Cover";
          };
        };
      };
    };
  };
}
