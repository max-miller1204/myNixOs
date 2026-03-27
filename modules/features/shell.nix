{ self, inputs, ... }: {
  flake.nixosModules.shell = { pkgs, lib, config, ... }: {
    options.features.shell.enable = lib.mkEnableOption "Fish shell with Starship and Atuin";

    config = lib.mkIf config.features.shell.enable {
      programs.fish.enable = true;
      users.users.${config.my.variables.username}.shell = pkgs.fish;

      home-manager.users.${config.my.variables.username} = {
        programs.fish = {
          enable = true;
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
  };
}
