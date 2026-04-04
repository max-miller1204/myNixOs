{ self, inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      services.upower.enable = true;
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "swaylock";
      environment.systemPackages = with pkgs; [
        noctalia-shell
        cava
      ];
    };

    provides.to-users.homeManager = { ... }: {
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;
    };
  };
}
