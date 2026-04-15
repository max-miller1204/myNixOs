{ inputs, den, ... }: {
  den.aspects.max = {
    includes = [
      den.aspects.shell
      den.aspects.git
      den.aspects.vim
      den.aspects.ghostty
      den.aspects.dev-tools
      den.aspects.tmux
      den.aspects.harnix
      den.aspects.mcp
      den.aspects.utilities
      den.aspects.media
      den.aspects.browsers
      den.aspects.catppuccin
      den.aspects.aerospace
      den.aspects.karabiner
      den.aspects.stt-nix
      den.aspects.thunar
      den.aspects.performance-profile
      den.aspects.hmPlatforms
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    hmLinux = { pkgs, ... }: {
      xdg.mimeApps.enable = true;
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;
      xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

      systemd.user.services.noctalia-shell = {
        Unit = {
          Description = "Noctalia shell (quickshell)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell";
          Restart = "on-failure";
          RestartSec = 3;
          Slice = "app.slice";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

    homeManager = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Claude Code dotfiles
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/spec".source = ./claude/skills/spec;
      home.file.".claude/plugins/lsp-servers/.claude-plugin/plugin.json".source = ./claude/lsp-servers/.claude-plugin/plugin.json;
    };
  };
}
