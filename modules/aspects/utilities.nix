{ self, inputs, ... }: {
  den.aspects.utilities = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        anki
        nvd
        pfetch-rs
        bubblewrap
      ];
    };
  };
}
