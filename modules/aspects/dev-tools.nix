{ self, inputs, ... }: {
  den.aspects.dev-tools = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nodejs
        cargo
        gcc
        rustc
        gh
        jq
        nixd
        ripgrep
        tree
        just
        neovim
        gum
        eza
        fd
        lazygit
        dust
        fastfetch
      ];
    };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        vscode
      ];
    };
  };
}
