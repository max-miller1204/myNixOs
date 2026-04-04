{ self, inputs, ... }: {
  den.aspects.utilities = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nvd
        pfetch-rs
      ];
    };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        anki
        bubblewrap
        unzip
        discord
      ];
    };
  };
}
