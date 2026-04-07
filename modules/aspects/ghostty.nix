{ self, inputs, ... }: {
  den.aspects.ghostty = {
    homeManager = { pkgs, ... }: {
      programs.ghostty = {
        enable = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 13;
          background-opacity = 0.75;
          theme = "catppuccin-mocha";
          window-decoration = false;
          confirm-close-surface = false;
          mouse-hide-while-typing = true;
          cursor-style = "block";
          copy-on-select = "clipboard";
        };
      };
    };
  };
}
