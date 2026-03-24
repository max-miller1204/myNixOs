{ self, inputs, ... }: {
  flake.nixosModules.alacritty = { pkgs, lib, config, ... }: {
    options.features.alacritty.enable = lib.mkEnableOption "Wrapped Alacritty terminal";

    config = lib.mkIf config.features.alacritty.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myAlacritty
      ];
    };
  };

  perSystem = { pkgs, ... }: {
    packages.myAlacritty = inputs.wrapper-modules.wrappers.alacritty.wrap {
      inherit pkgs;
      settings = {
        window.opacity = 0.75;
        keyboard.bindings = [
          { key = "Return"; mods = "Shift"; chars = "\\u001B\\r"; }
        ];
      };
    };
  };
}
