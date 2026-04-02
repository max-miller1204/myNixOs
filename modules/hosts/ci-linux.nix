{ ... }: {
  den.aspects.ci-linux = {
    nixos = { ... }: {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
    };
  };
}
