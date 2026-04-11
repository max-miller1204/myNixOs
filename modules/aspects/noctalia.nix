{ inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      services.upower.enable = true;
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "swaylock";
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.cava
      ];
    };

    provides.to-users.homeManager = { pkgs, ... }: {
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
