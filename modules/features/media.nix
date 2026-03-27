{ self, inputs, ... }: {
  flake.nixosModules.media = { pkgs, lib, config, ... }: {
    options.features.media.enable = lib.mkEnableOption "Media and document viewers";

    config = lib.mkIf config.features.media.enable {
      environment.systemPackages = with pkgs; [
        loupe
        zathura
      ];

      home-manager.users.${config.my.variables.username} = {
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
  };
}
