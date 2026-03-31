{ self, inputs, ... }: {
  den.aspects.karabiner = {
    hmDarwin = { ... }: {
      home.file.".config/karabiner/karabiner.json".source = ./karabiner/karabiner.json;
    };
  };
}
