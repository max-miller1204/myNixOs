{ self, inputs, ... }: {
  den.aspects.dev-tools = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nodejs
        gh
        jq
        ripgrep
        tree
        just
      ];
    };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        vscode
      ];
    };
  };
}
