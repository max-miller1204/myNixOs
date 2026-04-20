{ inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      services.upower.enable = true;
      # TODO: verify noctalia actually uses this PAM service. This setup uses
      # greetd, not swaylock — if noctalia's lock screen relies on this, switch
      # to "greetd" or whatever PAM service is registered for the lock flow.
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "swaylock";
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.cava
        pkgs.wl-clipboard
        pkgs.cliphist
      ];
    };

    hmLinux = { pkgs, ... }: {
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;

      systemd.user.services.noctalia-shell = {
        Unit = {
          Description = "Noctalia shell (quickshell)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell";
          Restart = "on-failure";
          RestartSec = 3;
          Slice = "app.slice";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
