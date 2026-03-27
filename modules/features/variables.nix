{ self, inputs, ... }: {
  flake.nixosModules.variables = { lib, ... }: {
    options.my.variables = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "max";
        description = "Primary user account name";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "vim";
        description = "Default text editor";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "alacritty";
        description = "Default terminal emulator";
      };
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "Default web browser";
      };
      monitor = lib.mkOption {
        type = lib.types.str;
        default = "eDP-1";
        description = "Primary monitor name";
      };
      secondaryMonitor = lib.mkOption {
        type = lib.types.str;
        default = "DP-3";
        description = "Secondary monitor name";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "maxmiller1204@outlook.com";
        description = "Primary email address";
      };
      location = lib.mkOption {
        type = lib.types.str;
        default = "Blacksburg";
        description = "Location name for weather and locale";
      };
      wallpaperDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/max/Pictures/Wallpapers";
        description = "Path to wallpaper directory";
      };
      avatarPath = lib.mkOption {
        type = lib.types.str;
        default = "/home/max/.face";
        description = "Path to user avatar image";
      };
      flakePath = lib.mkOption {
        type = lib.types.str;
        default = "/home/max/myNixOS";
        description = "Path to the NixOS flake directory";
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/New_York";
        description = "System timezone";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "System locale";
      };
      font = lib.mkOption {
        type = lib.types.str;
        default = "JetBrains Mono";
        description = "Default font family";
      };
      catppuccin = {
        flavor = lib.mkOption {
          type = lib.types.str;
          default = "mocha";
          description = "Catppuccin flavor (latte, frappe, macchiato, mocha)";
        };
        accent = lib.mkOption {
          type = lib.types.str;
          default = "mauve";
          description = "Catppuccin accent color";
        };
      };
    };
  };
}
