{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    code-cursor-nix.url = "github:max-miller1204/code-cursor-nix/fix/update-x86_64-linux-hash";
    claude-code.url = "github:sadjow/claude-code-nix";
    youtube-mcp-server.url = "github:max-miller1204/youtube-mcp-server-nix";
    opencode-nix.url = "github:max-miller1204/opencode-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    copilot-cli-nix.url = "github:max-miller1204/copilot-cli-nix";
    harnix.url = "github:max-miller1204/harnix";
    stt-nix.url = "github:max-miller1204/stt-nix";
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    (inputs.import-tree ./modules);
}
