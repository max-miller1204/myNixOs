{ inputs, den, ... }: {
  den.aspects.handy = {
    nixos = { ... }: {
      imports = [ inputs.handy.nixosModules.default ];

      programs.handy.enable = true;

      # rdev/handy-keys needs uinput for virtual input + /dev/input/* for hotkeys
      boot.kernelModules = [ "uinput" ];
      users.users.max.extraGroups = [ "input" ];
    };

    homeManager = { lib, ... }: {
      imports = [ inputs.handy.homeManagerModules.default ];

      # Handy is spawned at startup by Niri with --start-hidden.
      # The systemd service conflicts: on switch it hits the single-instance
      # plugin which doesn't handle --start-hidden and pops the GUI.
      services.handy.enable = false;
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
