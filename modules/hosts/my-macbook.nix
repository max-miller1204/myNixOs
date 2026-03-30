{ den, ... }: {
  den.aspects.my-macbook = {
    includes = [
      den.aspects.nix-settings
      den.aspects.darwin-base
      den.aspects.overlays
      den.aspects.homebrew
    ];

    darwin = { pkgs, ... }: {
      fonts.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];
    };
  };
}
