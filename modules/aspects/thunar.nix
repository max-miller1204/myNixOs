{ ... }: {
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
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
        	<icon>utilities-terminal</icon>
        	<name>Open Terminal Here</name>
        	<submenu></submenu>
        	<unique-id>1774637043391783-1</unique-id>
        	<command>ghostty --working-directory=%f</command>
        	<description>Open Ghostty in the current directory</description>
        	<range></range>
        	<patterns>*</patterns>
        	<startup-notify/>
        	<directories/>
        </action>
        </actions>
      '';
    };
  };
}
