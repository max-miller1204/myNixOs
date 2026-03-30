{ self, inputs, ... }: {
  den.aspects.catppuccin = {
    nixos = { pkgs, lib, ... }: {
      imports = [ inputs.catppuccin.nixosModules.catppuccin ];

      catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
      };
    };

    homeManager = { pkgs, lib, ... }: {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
        cursors.enable = true;
      };

      home.pointerCursor = lib.mkForce {
        name = "catppuccin-mocha-mauve-cursors";
        package = pkgs.catppuccin-cursors.mochaMauve;
        size = 24;
      };

      qt = {
        enable = true;
        platformTheme.name = "kvantum";
        style.name = "kvantum";
      };

      gtk.enable = true;
      gtk.gtk4.theme = null;
      catppuccin.gtk.icon.enable = true;

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
}
