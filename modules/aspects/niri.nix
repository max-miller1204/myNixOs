{ ... }: {
  den.aspects.niri = {
    nixos = { pkgs, lib, ... }: {
      programs.niri.enable = true;
      programs.niri.useNautilus = false;

      # Needed for stt-nix hold-to-talk (evdev).
      # Hardcoded because den's `os-user` forwarder drops `user.X` arriving
      # via `provides.to-users` — see https://github.com/vic/den/issues/473.
      # Switch to `provides.to-users.user.extraGroups = [ "input" ]` once fixed.
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

    hmLinux = { ... }: {
      xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
    };
  };
}
