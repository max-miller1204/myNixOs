{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }: {
    options.features.homeManager.enable = lib.mkEnableOption "Home Manager for primary user";

    imports = [ inputs.home-manager.nixosModules.home-manager ];

    config = lib.mkIf config.features.homeManager.enable {

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";

    home-manager.users.${config.my.variables.username} = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.stateVersion = "25.11";
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
  };
}
