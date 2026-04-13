{ ... }: {
  den.aspects.obsidian = {
    hmLinux = { pkgs, ... }: {
      home.packages = [ pkgs.obsidian ];
    };
  };
}
