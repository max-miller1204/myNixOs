{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";

    home-manager.users.max = { config, ... }: {
      home.stateVersion = "25.11";

      # Claude Code config
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/nix/SKILL.md".source = ./claude/skills/nix/SKILL.md;
    };
  };
}
