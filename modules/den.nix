{ inputs, lib, ... }: {
  imports = [ inputs.den.flakeModule ];

  # Define darwinConfigurations output option for flake-parts
  # (den generates it but flake-parts doesn't define the option)
  options.flake.darwinConfigurations = lib.mkOption {
    default = {};
    type = lib.types.lazyAttrsOf lib.types.raw;
  };
}
