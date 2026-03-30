{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
  imports =
    [
      self.nixosModules.myMachineHardware
      self.nixosModules.variables
      self.nixosModules.overlays
      self.nixosModules.niri
      self.nixosModules.homeManager
      self.nixosModules.alacritty
      self.nixosModules.git
      self.nixosModules.vim
      self.nixosModules.nvidia
      self.nixosModules.zram
      self.nixosModules.nh
      self.nixosModules.shell
      self.nixosModules.catppuccin
      self.nixosModules.thunar
      self.nixosModules.browsers
      self.nixosModules.devTools
      self.nixosModules.media
      self.nixosModules.utilities
      self.nixosModules.audio
      self.nixosModules.greetd
      self.nixosModules.bluetooth
      self.nixosModules.printing
      self.nixosModules.noctalia
      self.nixosModules.mcp
    ];

    # Enable feature modules
    features.overlays.enable = true;
    features.niri.enable = true;
    features.homeManager.enable = true;
    features.mcp.enable = true;
    features.alacritty.enable = true;
    features.git.enable = true;
    features.vim.enable = true;
    features.nvidia.enable = true;
    features.zram.enable = true;
    features.nh.enable = true;
    features.shell.enable = true;
    features.catppuccin.enable = true;
    features.thunar.enable = true;
    features.browsers.enable = true;
    features.devTools.enable = true;
    features.media.enable = true;
    features.utilities.enable = true;
    features.audio.enable = true;
    features.greetd.enable = true;
    features.bluetooth.enable = true;
    features.printing.enable = true;

    # flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Automatic garbage collection and store optimization
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    nix.settings.auto-optimise-store = true;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    # Timezone and locale
    time.timeZone = config.my.variables.timezone;
    i18n.defaultLocale = config.my.variables.locale;
    i18n.extraLocaleSettings = let locale = config.my.variables.locale; in {
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

    users.users.${config.my.variables.username} = {
      isNormalUser = true;
      description = config.my.variables.username;
      extraGroups = [ "networkmanager" "wheel" ];
    };

    # Enable askpass so sudo works from non-terminal contexts (e.g. Claude Code)
    programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    environment.sessionVariables.SUDO_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";

    nixpkgs.config.allowUnfree = true;

    # Fonts
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];

    system.stateVersion = "25.11";
  };
}
