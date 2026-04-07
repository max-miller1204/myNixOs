{ self, inputs, ... }: {
  den.aspects.nix-settings = {
    os = { ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.extra-substituters = [
        "https://cache.garnix.io"
      ];
      nix.settings.extra-trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
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

      # Keep /tmp tidy: wipe on boot and remove files older than 7 days.
      boot.tmp.cleanOnBoot = true;
      systemd.tmpfiles.rules = [
        "d /tmp 1777 root root 7d -"
      ];
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
