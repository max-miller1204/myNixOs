{ self, inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.antigravity-nix.overlays.default
        inputs.codex-cli-nix.overlays.default
        inputs.copilot-cli-nix.overlays.default
        inputs.oh-my-codex-nix.overlays.default
        inputs.oh-my-openagent-nix.overlays.default
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        antigravity
        codex
        github-copilot-cli
        opencode
        oh-my-codex
        oh-my-openagent
      ];

      # Run omx-activate as user after rebuild (only triggers on version change)
      system.activationScripts.omx-activate = {
        text = ''
          if [ -x "${pkgs.oh-my-codex}/bin/omx-activate" ]; then
            ${pkgs.sudo}/bin/sudo -u max \
              HOME=/home/max \
              ${pkgs.oh-my-codex}/bin/omx-activate || true
          fi
        '';
      };
    };
  };
}
