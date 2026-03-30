{ self, inputs, ... }: {
  den.aspects.browsers = {
    nixos = { pkgs, ... }: {
      programs.firefox.enable = true;
      environment.systemPackages = [ pkgs.google-chrome ];
    };

    homeManager = { ... }: {
      xdg.mimeApps.defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
  };
}
