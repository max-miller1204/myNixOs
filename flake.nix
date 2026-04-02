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

    antigravity-nix.url = "github:jacopone/antigravity-nix";
    claude-code.url = "github:sadjow/claude-code-nix";
    youtube-mcp-server.url = "github:max-miller1204/youtube-mcp-server-nix";
    opencode-nix.url = "github:max-miller1204/opencode-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    copilot-cli-nix.url = "github:max-miller1204/copilot-cli-nix";
    oh-my-codex-nix.url = "github:max-miller1204/oh-my-codex-nix";
    oh-my-openagent-nix.url = "github:max-miller1204/oh-my-openagent-nix";
    nix-npm-globals.url = "github:max-miller1204/nix-npm-globals";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake
    {inherit inputs;}
    (inputs.import-tree ./modules);
}
