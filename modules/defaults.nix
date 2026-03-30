{ den, ... }: {
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";

    includes = [
      den.aspects.overlays
      den.aspects.catppuccin
      den.aspects.hmPlatforms
    ];
  };
}
