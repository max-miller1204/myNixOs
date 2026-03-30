{ self, inputs, ... }: {
  den.aspects.media = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        loupe
        zathura
      ];
    };

    homeManager = { ... }: {
      xdg.mimeApps.defaultApplications = {
        "image/png" = [ "org.gnome.Loupe.desktop" ];
        "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
        "image/gif" = [ "org.gnome.Loupe.desktop" ];
        "image/webp" = [ "org.gnome.Loupe.desktop" ];
        "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
}
