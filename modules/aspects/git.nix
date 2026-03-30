{ self, inputs, ... }: {
  den.aspects.git = {
    homeManager = { pkgs, ... }: {
      programs.git = {
        enable = true;
        settings = {
          user.name = "max";
          user.email = "maxmiller1204@outlook.com";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
        };
      };
    };
  };
}
