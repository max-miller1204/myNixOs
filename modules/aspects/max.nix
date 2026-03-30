{ inputs, den, ... }: {
  den.aspects.max = {
    includes = [
      den.aspects.shell
      den.aspects.git
      den.aspects.vim
      den.aspects.alacritty
      den.aspects.dev-tools
      den.aspects.mcp
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    homeManager = { config, pkgs, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      xdg.mimeApps.enable = true;
      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Claude Code dotfiles
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/nix/SKILL.md".source = ./claude/skills/nix/SKILL.md;
    };
  };
}
