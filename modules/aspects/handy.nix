{ inputs, den, ... }: {
  den.aspects.handy = {
    nixos = { ... }: {
      imports = [ inputs.handy.nixosModules.default ];

      programs.handy.enable = true;

      # rdev/handy-keys needs uinput for virtual input + /dev/input/* for hotkeys
      boot.kernelModules = [ "uinput" ];
      users.users.max.extraGroups = [ "input" ];
    };

    homeManager = { ... }: {
      imports = [ inputs.handy.homeManagerModules.default ];

      services.handy.enable = true;
    };

    # Wayland runtime tools for clipboard and paste simulation
    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        wl-clipboard # wl-copy/wl-paste for Wayland clipboard
        wtype        # virtual keyboard input for Wayland paste
      ];
    };
  };
}
