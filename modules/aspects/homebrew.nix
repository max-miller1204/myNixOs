{ self, inputs, ... }: {
  den.aspects.homebrew = {
    darwin = { ... }: {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "none";
        };
        brews = [
          "cosign"
          "direnv"
          "fastfetch"
          "llama.cpp"
          "mise"
          "podman"
          "poppler"
          "uv"
        ];
        casks = [
          "aerospace"
          "antigravity"
          "balenaetcher"
          "claude"
          "claude-code@latest"
          "codex"
          "font-jetbrains-mono-nerd-font"
          "karabiner-elements"
          "macdown-3000"
          "neovide-app"
          "pearcleaner"
          "raycast"
          "spotify"
          "utm"
          "visual-studio-code"
          "zed"
          "copilot-cli"
        ];
      };
    };
  };
}
