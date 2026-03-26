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

        # Force dark color scheme for GTK/libadwaita apps
        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  };
}
