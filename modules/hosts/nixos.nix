{ den, ... }: {
  den.aspects.nixos = {
    includes = [
      den.aspects.nix-settings
      den.aspects.overlays
      den.aspects.niri
      den.aspects.noctalia
      den.aspects.greetd
      den.aspects.nvidia
      den.aspects.audio
      den.aspects.bluetooth
      den.aspects.printing
      den.aspects.zram
      den.aspects.thunar
      den.aspects.fingerprint
    ];

    nixos = { pkgs, ... }: {
      imports = [ ../../hardware/my-machine.nix ];

      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Networking
      networking.networkmanager.enable = true;

      # Run generic dynamically linked Linux binaries.
      programs.nix-ld.enable = true;

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
