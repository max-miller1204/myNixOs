{ lib, ... }:
let
  secretFile = ../../secrets/youtube.sops.yaml;
  hasSecretFile = builtins.pathExists secretFile;
in
{
  flake.nixosModules.youtubeSecret = { config, ... }: {
    options.features.youtubeSecret.enable = lib.mkEnableOption "YouTube SOPS secret";

    config = lib.mkIf config.features.youtubeSecret.enable {
      sops = lib.optionalAttrs hasSecretFile {
        secrets.youtube_api_key = {
          sopsFile = secretFile;
          format = "yaml";
          mode = "0400";
          owner = "max";
        };
      };

      warnings = lib.optionals (!hasSecretFile) [
        "YouTube secret file is missing: secrets/youtube.sops.yaml. YouTube MCP wrapper will fail until the secret is created."
      ];
    };
  };
}
