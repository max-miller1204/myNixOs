{ ... }: {
  den.aspects.media = {
    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        loupe
        zathura
      ];

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
