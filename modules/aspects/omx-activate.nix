{ ... }: {
  den.aspects.omx-activate = {
    nixos = { pkgs, ... }: {
      # Run omx-activate as user after rebuild (only triggers on version change)
      system.activationScripts.omx-activate = {
        text = ''
          if [ -x "${pkgs.oh-my-codex}/bin/omx-activate" ]; then
            ${pkgs.sudo}/bin/sudo -u max \
              HOME=/home/max \
              PATH=${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.nodejs}/bin:$PATH \
              ${pkgs.oh-my-codex}/bin/omx-activate || true
          fi
        '';
      };
    };
  };
}
