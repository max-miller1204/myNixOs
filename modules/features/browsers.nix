{ self, inputs, ... }: {
  flake.nixosModules.browsers = { pkgs, lib, config, ... }: {
    options.features.browsers.enable = lib.mkEnableOption "Web browsers";

    config = lib.mkIf config.features.browsers.enable {
      programs.firefox.enable = true;

      environment.systemPackages = with pkgs; [
        google-chrome
      ];

      home-manager.users.${config.my.variables.username} = {
        xdg.mimeApps.defaultApplications = {
          "text/html" = [ "firefox.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
        };
      };
    };
  };
}
