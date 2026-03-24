{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, lib, config, ... }: {
    options.features.git.enable = lib.mkEnableOption "Wrapped Git with bundled config";

    config = lib.mkIf config.features.git.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myGit
      ];
    };
  };

  perSystem = { pkgs, ... }: {
    packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings = {
        user = {
          name = "max";
          email = "maxmiller1204@outlook.com";
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };
  };
}
