{ self, inputs, ... }: {
  flake.nixosModules.devTools = { pkgs, lib, config, ... }: {
    options.features.devTools.enable = lib.mkEnableOption "Development tools";

    config = lib.mkIf config.features.devTools.enable {
      environment.systemPackages = with pkgs; [
        codex
        nodejs
        vscode
        gh
        jq
        ripgrep
        tree
        just
      ];
    };
  };
}
