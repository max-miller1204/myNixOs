{ self, inputs, ... }: {
  den.aspects.ci-linux = {
    nixos = { ... }: {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      users.users.runner.isNormalUser = true;
    };
  };
}
