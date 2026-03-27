{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, lib, config, ... }: {
    options.features.git.enable = lib.mkEnableOption "Git with user config";

    config = lib.mkIf config.features.git.enable {
      home-manager.users.${config.my.variables.username} = {
        programs.git = {
          enable = true;
          settings = {
            user = {
              name = config.my.variables.username;
              email = config.my.variables.email;
            };
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            pull.rebase = true;
            credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
          };
        };
      };
    };
  };
}
