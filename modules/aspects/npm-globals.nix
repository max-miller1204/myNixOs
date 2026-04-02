{ self, inputs, ... }: {
  den.aspects.npm-globals = {
    homeManager = { ... }: {
      imports = [ inputs.nix-npm-globals.homeManagerModules.default ];

      programs.npm-globals = {
        enable = true;

        # Add packages here. Version pinning supported:
        #   "pkg"         → installs latest
        #   "pkg@1.2.3"   → pins to exact version
        #   "@scope/pkg"  → scoped package
        npmPackages = [
          # "@anthropic-ai/claude-code"
          # "@mariozechner/pi-coding-agent"
          # "gsd-pi"
        ];

        bunPackages = [
          # Add bun global packages here
        ];
      };
    };
  };
}
