{ ... }: {
  den.aspects.alacritty = {
    homeManager = { ... }: {
      programs.alacritty = {
        enable = true;
        settings = {
          window.opacity = 0.75;
          keyboard.bindings = [
            { key = "Return"; mods = "Shift"; chars = "\\u001B\\r"; }
          ];
        };
      };
    };
  };
}
