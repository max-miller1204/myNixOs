{ self, inputs, ... }: {
  den.aspects.printing = {
    nixos = { ... }: {
      services.printing.enable = true;
    };
  };
}
