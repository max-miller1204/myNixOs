{ self, inputs, ... }: {
  flake.nixosModules.vim = { pkgs, lib, config, ... }: {
    options.features.vim.enable = lib.mkEnableOption "Wrapped Vim with bundled config";

    config = lib.mkIf config.features.vim.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myVim
      ];
    };
  };

  perSystem = { pkgs, ... }: {
    packages.myVim = inputs.wrapper-modules.wrappers.vim.wrap {
      inherit pkgs;
      vimrc = ''
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
}
