{ den, ... }: {
  den.aspects.my-machine = {
    includes = [
      den.aspects.niri
      den.aspects.noctalia
      den.aspects.greetd
      den.aspects.nvidia
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.zram
      den.aspects.thunar
      den.aspects.browsers
      den.aspects.media
      den.aspects.utilities
      den.aspects.nh
      den.aspects.fingerprint
    ];

    nixos = { config, pkgs, ... }: {
      imports = [ ../../hardware/my-machine.nix ];

      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Networking
      networking.hostName = "nixos";
      networking.networkmanager.enable = true;

      # Timezone and locale
      time.timeZone = "America/New_York";
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = let locale = "en_US.UTF-8"; in {
        LC_ADDRESS = locale;
        LC_IDENTIFICATION = locale;
        LC_MEASUREMENT = locale;
        LC_MONETARY = locale;
        LC_NAME = locale;
        LC_NUMERIC = locale;
        LC_PAPER = locale;
        LC_TELEPHONE = locale;
        LC_TIME = locale;
      };

      # Nix settings
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      nix.settings.auto-optimise-store = true;
      nixpkgs.config.allowUnfree = true;

      # User
      users.users.max = {
        isNormalUser = true;
        description = "max";
        extraGroups = [ "networkmanager" "wheel" ];
      };

      # SSH askpass
      programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
      environment.sessionVariables.SUDO_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";

      # Fonts
      fonts.packages = with pkgs; [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];
    };
  };
}
