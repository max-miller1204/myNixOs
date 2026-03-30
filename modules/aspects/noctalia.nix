{ self, inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      services.upower.enable = true;
      environment.systemPackages = with pkgs; [
        noctalia-shell
        cava
      ];
    };

    homeManager = { ... }: {
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;
    };
  };
}
