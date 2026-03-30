{ self, inputs, ... }: {
  den.aspects.shell = {
    homeManager = { ... }: {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting
          pfetch
        '';
        shellAliases = {
          ll = "ls -la";
          la = "ls -a";
          gs = "git status";
          gc = "git commit";
          gp = "git push";
          gl = "git log --oneline";
          rebuild = "just switch";
        };
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.atuin = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          auto_sync = false;
          update_check = false;
          style = "compact";
          inline_height = 10;
        };
      };

      programs.bat.enable = true;
      programs.fzf.enable = true;
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
