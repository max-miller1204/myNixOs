{ lib, den, ... }: {
  # Enable the `user` class alongside home-manager so aspects can forward
  # OS-level user config (e.g. extraGroups) via `provides.to-users.user.*`
  # instead of hardcoding `users.users.<name>.*` in host aspects.
  den.schema.user.classes = lib.mkDefault [ "homeManager" "user" ];

  # Class forwarding: hmLinux/hmDarwin → homeManager with platform guards
  # Enables aspects to have platform-specific HM config:
  #   den.aspects.foo.hmLinux = { ... };   # only on Linux
  #   den.aspects.foo.hmDarwin = { ... };  # only on macOS
  den.aspects.hmPlatforms =
    { aspect-chain, ... }:
    den._.forward {
      each = [ "Linux" "Darwin" ];
      fromClass = platform: "hm${platform}";
      intoClass = _: "homeManager";
      intoPath = _: [];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = { config, ... }: { osConfig = config; };
      guard = { pkgs, ... }: platform: lib.mkIf pkgs.stdenv."is${platform}";
    };
}
