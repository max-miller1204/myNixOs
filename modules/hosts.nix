{ inputs, config, ... }: {
  den.hosts.x86_64-linux.nixos.users.max = {};
  den.hosts.aarch64-darwin.my-macbook.users.max = {};

  den.hosts.x86_64-linux.ci-linux = {};
  den.hosts.aarch64-darwin.ci-darwin = {};

  # Standalone home-manager target for Ubuntu (or any non-NixOS Linux).
  # Activate on the target machine with:
  #   home-manager switch --flake github:max-miller1204/myNixOs#max@ubuntu
  # Override pkgs to enable allowUnfree (the OS-level setting in nix-settings
  # doesn't reach standalone homes since home-manager receives a pre-built pkgs).
  den.homes.x86_64-linux."max@ubuntu" = {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "electron-38.8.4" ];
      overlays = [ config.flake.overlays.default ];
    };
  };
}
