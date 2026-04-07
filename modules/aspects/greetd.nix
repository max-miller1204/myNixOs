{ ... }: {
  den.aspects.greetd = {
    nixos = { ... }: {
      programs.regreet = {
        enable = true;
        cageArgs = [ "-m" "last" ];
        settings = {
          default_session.command = "niri-session";
          background = {
            path = ./wallpaper.png;
            fit = "Cover";
          };
        };
      };
    };
  };
}
