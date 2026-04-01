{ self, inputs, ... }: {
  den.aspects.git = {
    homeManager = { pkgs, ... }: {
      programs.git = {
        enable = true;
        settings = {
          alias = {
            sync = "!git stash push -u -m \"wip: pre-sync\" && git pull --rebase && git stash pop && git restore --source=HEAD -- flake.lock";
          };
          user.name = "max";
          user.email = "maxmiller1204@outlook.com";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          credential."https://github.com".helper = "!gh auth git-credential";
        };
      };
    };
  };
}
