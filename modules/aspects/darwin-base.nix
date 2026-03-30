{ self, inputs, ... }: {
  den.aspects.darwin-base = {
    darwin = { pkgs, ... }: {
      system.defaults.trackpad.Clicking = true;
      system.defaults.trackpad.TrackpadThreeFingerDrag = true;
      system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  };
}
