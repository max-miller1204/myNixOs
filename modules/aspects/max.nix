{ inputs, den, ... }: {
  den.aspects.max = {
    includes = [
      den.aspects.shell
      den.aspects.git
      den.aspects.vim
      den.aspects.alacritty
      den.aspects.dev-tools
      den.aspects.harnix
      den.aspects.handy
      den.aspects.mcp
      den.aspects.utilities
      den.aspects.media
      den.aspects.browsers
      den.aspects.catppuccin
      den.aspects.aerospace
      den.aspects.karabiner
      den.aspects.hmPlatforms
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    hmLinux = { ... }: {
      xdg.mimeApps.enable = true;
      xdg.configFile."noctalia/settings.json".source = ./noctalia/settings.json;
    };

    homeManager = { config, pkgs, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Claude Code dotfiles
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/spec".source = ./claude/skills/spec;
      home.file.".claude/skills/nix/SKILL.md".source = ./claude/skills/nix/SKILL.md;
    };
  };
}
