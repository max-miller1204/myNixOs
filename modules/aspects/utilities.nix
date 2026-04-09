{ self, inputs, ... }: {
  den.aspects.utilities = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        btop
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
