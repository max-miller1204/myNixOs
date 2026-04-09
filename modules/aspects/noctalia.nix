{ inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      imports = [ inputs.noctalia.nixosModules.default ];
      services.upower.enable = true;
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "swaylock";
      environment.systemPackages = with pkgs; [
        cava
      ];
    };

    provides.to-users.homeManager = { ... }: {
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;
    };
  };
}
