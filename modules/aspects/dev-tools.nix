{ self, inputs, ... }: {
  den.aspects.dev-tools = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nodejs
        cargo
        rustc
        gh
        jq
        nixd
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
