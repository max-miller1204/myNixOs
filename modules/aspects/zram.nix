{ self, inputs, ... }: {
  den.aspects.zram = {
    nixos = { ... }: {
      zramSwap.enable = true;
      zramSwap.algorithm = "zstd";
    };
  };
}
