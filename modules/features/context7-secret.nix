{ inputs, lib, ... }:
let
  secretFile = ../../secrets/context7.sops.yaml;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  flake.nixosModules.context7Secret = { config, ... }: {
    options.features.context7Secret.enable = lib.mkEnableOption "Context7 SOPS secret";

    imports = [ inputs.sops-nix.nixosModules.sops ];

    config = lib.mkIf config.features.context7Secret.enable {
      sops = {
        # Use a per-user age key file so secret bootstrap works without extra root key setup.
        age.keyFile = "/home/max/.config/sops/age/keys.txt";
        age.generateKey = false;
      } // lib.optionalAttrs hasSecretFile {
        defaultSopsFile = secretFile;
        defaultSopsFormat = "yaml";
        secrets.context7_api_key = {
          mode = "0400";
          owner = "max";
        };
      };

      warnings = lib.optionals (!hasSecretFile) [
        "context7 secret file is missing: secrets/context7.sops.yaml. Context7 wrapper will fail until the secret is created."
      ];
    };
  };
}
