{ self, inputs, ... }: {
  flake.nixosModules.vim = { pkgs, lib, config, ... }: {
    options.features.vim.enable = lib.mkEnableOption "Vim with Catppuccin and custom config";

    config = lib.mkIf config.features.vim.enable {
      home-manager.users.${config.my.variables.username} = {
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
  };
}
