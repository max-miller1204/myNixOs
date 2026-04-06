{ self, inputs, ... }: {
  den.aspects.harnix = {
    homeManager = { ... }: {
      imports = [ inputs.harnix.homeManagerModules.default ];

      programs.harnix = {
        enable = true;

        # Add packages here. Version pinning supported:
        #   "pkg"         → installs latest
        #   "pkg@1.2.3"   → pins to exact version
        #   "@scope/pkg"  → scoped package
        npmPackages = [
          # "@anthropic-ai/claude-code"
          # "@mariozechner/pi-coding-agent"
          "oh-my-codex"
          "gsd-pi@latest"
          "dmux"
        ];

        bunPackages = [
          "oh-my-opencode-slim@latest --reset --no-tui --tmux=yes --skills=yes"
          "ruflo@latest"
        ];
      };
    };
  };
}
