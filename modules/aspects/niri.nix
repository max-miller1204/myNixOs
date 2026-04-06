{ self, inputs, ... }: {
  den.aspects.niri = {
    nixos = { pkgs, ... }: {
      programs.niri.enable = true;
      programs.niri.useNautilus = false;

      # Needed for stt-nix hold-to-talk (evdev)
      users.users.max.extraGroups = [ "input" ];

      xdg.portal = {
        xdgOpenUsePortal = true;
        config.common.default = [ "gtk" ];
      };

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        brightnessctl
      ];
    };

    provides.to-users.homeManager = { ... }: {
      xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
    };
  };
}
