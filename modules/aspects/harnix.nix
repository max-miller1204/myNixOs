{ inputs, ... }: {
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
          "oh-my-codex"
        ];

        bunPackages = [ ];
      };
    };
  };
}
