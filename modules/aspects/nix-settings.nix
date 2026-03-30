{ self, inputs, ... }: {
  den.aspects.nix-settings = {
    os = { ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.optimise.automatic = true;
      nixpkgs.config.allowUnfree = true;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
    };

    nixos = { ... }: {
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    darwin = { ... }: {
      nix.gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 2; Minute = 0; };
        options = "--delete-older-than 7d";
      };
    };
  };
}
