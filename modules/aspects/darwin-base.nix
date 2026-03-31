{ self, inputs, ... }: {
  den.aspects.darwin-base = {
    darwin = { pkgs, ... }: {
      environment.shells = [ pkgs.fish ];
      # Trackpad
      system.defaults.trackpad.Clicking = true;
      system.defaults.trackpad.TrackpadThreeFingerDrag = true;

      # Keyboard
      system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;

      # Dock
      system.defaults.dock.autohide = true;

      # Finder
      system.defaults.finder.AppleShowAllExtensions = true;
      system.defaults.NSGlobalDomain.AppleShowAllFiles = true;

      # Security
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  };
}
