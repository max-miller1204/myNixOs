{ self, inputs, ... }: {
  flake.nixosModules.catppuccin = { pkgs, lib, config, ... }: {
    options.features.catppuccin.enable = lib.mkEnableOption "Catppuccin system-wide theming";

    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    config = lib.mkIf config.features.catppuccin.enable {
      catppuccin = {
        enable = true;
        flavor = config.my.variables.catppuccin.flavor;
        accent = config.my.variables.catppuccin.accent;
      };

      home-manager.users.${config.my.variables.username} = {
        imports = [ inputs.catppuccin.homeModules.catppuccin ];

        catppuccin = {
          enable = true;
          flavor = config.my.variables.catppuccin.flavor;
          accent = config.my.variables.catppuccin.accent;
          cursors.enable = true;
        };

        home.pointerCursor = lib.mkForce {
          name = "catppuccin-mocha-mauve-cursors";
          package = pkgs.catppuccin-cursors.mochaMauve;
          size = 24;
        };

        # Qt theming
        qt = {
          enable = true;
          platformTheme.name = "kvantum";
          style.name = "kvantum";
        };

        # GTK settings management + catppuccin icon theme
        gtk.enable = true;
        gtk.gtk4.theme = null;
        catppuccin.gtk.icon.enable = true;

        # Dark mode: dconf for GTK4/libadwaita, gtk3 setting for Thunar etc.
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      };
    };
  };
}
