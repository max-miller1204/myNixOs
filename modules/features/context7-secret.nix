{ lib, ... }:
let
  secretFile = ../../secrets/context7.sops.yaml;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  flake.nixosModules.context7Secret = { config, ... }: {
    options.features.context7Secret.enable = lib.mkEnableOption "Context7 SOPS secret";

    config = lib.mkIf config.features.context7Secret.enable {
      sops = lib.optionalAttrs hasSecretFile {
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
