{ ... }: {
  # Overlay example for future use.
  # Uncomment and modify when you need to patch or override packages.
  #
  # flake.nixosModules.overlays = { ... }: {
  #   nixpkgs.overlays = [
  #     (final: prev: {
  #       # Override an existing package:
  #       # myPackage = prev.myPackage.override { enableFeature = true; };
  #
  #       # Add a custom package:
  #       # myTool = final.callPackage ./packages/myTool { };
  #     })
  #   ];
  # };
}
