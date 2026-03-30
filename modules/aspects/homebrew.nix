{ self, inputs, ... }: {
  den.aspects.homebrew = {
    darwin = { ... }: {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "none";
        };
        brews = [];
        casks = [
          "visual-studio-code"
          "claude"
          "antigravity"
        ];
      };
    };
  };
}
