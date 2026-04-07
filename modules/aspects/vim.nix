{ ... }: {
  den.aspects.vim = {
    homeManager = { pkgs, ... }: {
      programs.vim = {
        enable = true;
        plugins = [ pkgs.vimPlugins.catppuccin-vim ];
        extraConfig = ''
          set background=dark
          set termguicolors
          colorscheme catppuccin_mocha
          set number
          set relativenumber
          set tabstop=2
          set shiftwidth=2
          set expandtab
          set smartindent
          set ignorecase
          set smartcase
          set hlsearch
          set incsearch
          set clipboard=unnamedplus
        '';
      };
    };
  };
}
