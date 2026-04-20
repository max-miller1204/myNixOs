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

    hmLinux = { ... }: {
      xdg.mimeApps.enable = true;
    };

    homeManager = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # Surface a clear error when activating a fresh standalone home (e.g. on
      # Ubuntu) before the age key has been copied over, instead of failing
      # mid-activation with a cryptic decryption error.
      home.activation.checkSopsKey = config.lib.dag.entryBefore [ "writeBoundary" ] ''
        if [ ! -f "${config.sops.age.keyFile}" ]; then
          echo "" >&2
          echo "ERROR: sops age key not found at ${config.sops.age.keyFile}" >&2
          echo "Copy it from your NixOS host before running home-manager switch:" >&2
          echo "  mkdir -p ~/.config/sops/age" >&2
          echo "  scp <nixos-host>:~/.config/sops/age/keys.txt ~/.config/sops/age/" >&2
          echo "" >&2
          exit 1
        fi
      '';

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
