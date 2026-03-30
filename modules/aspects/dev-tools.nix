{ self, inputs, ... }: {
  den.aspects.dev-tools = {
    nixos = { pkgs, ... }: {
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
