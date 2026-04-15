{ self, inputs, ... }: {
  den.aspects.utilities = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        btop
        nvd
        pfetch-rs
        poppler-utils
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
