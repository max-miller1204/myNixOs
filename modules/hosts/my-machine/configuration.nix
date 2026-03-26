{ self, inputs, ... }: {

  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
    nixpkgs.overlays = [
      inputs.claude-code.overlays.default
    ];
  imports =
    [
      self.nixosModules.myMachineHardware
      self.nixosModules.variables
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
    ];

    # Enable feature modules
    features.niri.enable = true;
    features.homeManager.enable = true;
    features.alacritty.enable = true;
    features.git.enable = true;
    features.vim.enable = true;
    features.nvidia.enable = true;
    features.zram.enable = true;
    features.nh.enable = true;
    features.shell.enable = true;
    features.catppuccin.enable = true;

    # flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Automatic garbage collection and store optimization
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    nix.settings.auto-optimise-store = true;

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = config.my.variables.timezone;

    # Select internationalisation properties.
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

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don’t forget to set a password with ‘passwd’.
    users.users.${config.my.variables.username} = {
      isNormalUser = true;
      description = config.my.variables.username;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      #  thunderbird
      ];
    };

    # Install firefox.
    programs.firefox.enable = true;

    # Enable askpass so sudo works from non-terminal contexts (e.g. Claude Code)
    programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    environment.sessionVariables.SUDO_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      claude-code
      nodejs
      bubblewrap
      gh
      jq
      ripgrep
      tree
      vscode
      anki
      just
      nvd
    ];

    # Fonts
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:
    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
