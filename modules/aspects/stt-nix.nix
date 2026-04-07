{ inputs, ... }: {
  den.aspects.stt-nix = {
    nixos = {
      # dotool needs /dev/uinput to synthesise keystrokes for paste
      boot.kernelModules = [ "uinput" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660"
      '';
    };

    homeManager = { ... }: {
      imports = [ inputs.stt-nix.homeManagerModules.default ];
    };

    hmLinux = { config, pkgs, ... }: {
      sops.secrets.groq_api_key = {
        sopsFile = ../../secrets/groq.sops.yaml;
        path = "${config.home.homeDirectory}/.config/stt-nix/groq-api-key";
      };

      # Give the tray host (StatusNotifierWatcher) time to appear
      systemd.user.services.stt-nix.Service.ExecStartPre =
        "${pkgs.coreutils}/bin/sleep 3";

      services.stt-nix = {
        enable = true;
        package = pkgs.stt-nix;
        groqApiKeyFile = config.sops.secrets.groq_api_key.path;
        settings = {
          transcription = {
            backend = "groq";
            language = "en";
          };
          output.paste_key = "ctrl+shift+v";
          hotkey = {
            enabled = true;
            key = "capslock";
            mode = "hold";
          };
        };
      };
    };
  };
}
