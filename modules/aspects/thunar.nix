{ self, inputs, ... }: {
  den.aspects.thunar = {
    nixos = { pkgs, ... }: {
      programs.thunar = {
        enable = true;
        plugins = [ pkgs.thunar-volman ];
      };
      services.gvfs.enable = true;
      services.tumbler.enable = true;
    };

    homeManager = { ... }: {
      xdg.mimeApps.defaultApplications = {
        "inode/directory" = [ "thunar.desktop" ];
      };
      xdg.configFile."xfce4/helpers.rc".text = ''
        TerminalEmulator=alacritty
        TerminalEmulatorDismissed=true
      '';
    };
  };
}
