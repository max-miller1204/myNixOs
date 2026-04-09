{ ... }: {
  den.aspects.niri = {
    nixos = { pkgs, lib, ... }: {
      programs.niri.enable = true;
      programs.niri.useNautilus = false;

      # Needed for stt-nix hold-to-talk (evdev)
      users.users.max.extraGroups = [ "input" ];

      xdg.portal = {
        xdgOpenUsePortal = true;
        config.common.default = [ "gtk" ];
      };

      # Reload niri config on rebuild without needing to log out
      system.userActivationScripts.niri-reload-config.text = lib.getExe (
        pkgs.writeShellApplication {
          name = "niri-reload-config";
          runtimeInputs = [ pkgs.procps ];
          text = ''
            if pgrep -x "niri" > /dev/null; then
              NIRI_SOCKET=$(find "/run/user/$(id -u)" -name 'niri.*' -type s 2>/dev/null | head -1)
              if [ -n "$NIRI_SOCKET" ]; then
                NIRI_SOCKET="$NIRI_SOCKET" niri msg action load-config-file || true
              fi
            fi
          '';
        }
      );

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        brightnessctl
      ];
    };

    # config.kdl deployed via max.nix hmLinux (provides.to-users wasn't deploying)
  };
}
