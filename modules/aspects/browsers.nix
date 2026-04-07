{ ... }: {
  den.aspects.browsers = {
    nixos = { ... }: {
      programs.firefox.enable = true;
    };

    hmLinux = { pkgs, ... }: {
      home.packages = [ pkgs.google-chrome ];
      xdg.mimeApps.defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
  };
}
