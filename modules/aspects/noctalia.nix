{ inputs, ... }: {
  den.aspects.noctalia = {
    nixos = { pkgs, ... }: {
      services.upower.enable = true;
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "swaylock";
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.cava
        pkgs.wl-clipboard
        pkgs.cliphist
      ];
    };

    # settings.json and the user systemd unit are deployed via max.nix hmLinux
    # (provides.to-users.homeManager isn't deploying — see niri.nix:37).
  };
}
