{ self, inputs, ... }: {
  flake.nixosModules.alacritty = { pkgs, lib, config, ... }: {
    options.features.alacritty.enable = lib.mkEnableOption "Alacritty terminal with Catppuccin theming";

    config = lib.mkIf config.features.alacritty.enable {
      home-manager.users.${config.my.variables.username} = {
        programs.alacritty = {
          enable = true;
          settings = {
            window.opacity = 0.75;
            keyboard.bindings = [
              { key = "Return"; mods = "Shift"; chars = "\\u001B\\r"; }
            ];
          };
        };
      };
    };
  };
}
