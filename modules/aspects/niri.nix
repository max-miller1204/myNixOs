{ ... }: {
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

    # config.kdl deployed via max.nix hmLinux (provides.to-users wasn't deploying)
  };
}
