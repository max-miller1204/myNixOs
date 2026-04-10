{ ... }: {
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
        typescript-language-server
        rust-analyzer
        pyright
        lua-language-server
        vscode-langservers-extracted
        clang-tools
        haskell-language-server
        sourcekit-lsp
        marksman
        (rWrapper.override {
          packages = with rPackages; [
            languageserver
          ];
        })
        panache
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
        tree-sitter
        imagemagick
        trash-cli
        ghostscript
        sqlite
        luarocks
        lua5_1
        python3
      ];
    };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        vscode
        rstudio
      ];
    };
  };
}
