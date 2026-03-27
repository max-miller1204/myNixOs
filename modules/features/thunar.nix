{ ... }: {
  flake.nixosModules.thunar = { pkgs, lib, config, ... }: {
    options.features.thunar.enable = lib.mkEnableOption "Thunar file manager";

    config = lib.mkIf config.features.thunar.enable {
      programs.thunar = {
        enable = true;
        plugins = [
          pkgs.thunar-volman
        ];
      };
      services.gvfs.enable = true;
      services.tumbler.enable = true;

      # Thunar uses XFCE's helper system for "Open in Terminal"
      home-manager.users.${config.my.variables.username} = {
        xdg.configFile."xfce4/helpers.rc".text = ''
          TerminalEmulator=${config.my.variables.terminal}
          TerminalEmulatorDismissed=true
        '';
      };
    };
  };
}
