{ inputs, ... }: {
  den.aspects.overlays = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.claude-code.overlays.default
        inputs.codex-cli-nix.overlays.default
        inputs.stt-nix.overlays.default
        (final: prev: {
          brev-cli = prev.stdenv.mkDerivation (finalAttrs: {
            pname = "brev-cli";
            version = "0.6.322";
            src = prev.fetchurl {
              url = "https://github.com/brevdev/brev-cli/releases/download/v${finalAttrs.version}/brev-cli_${finalAttrs.version}_linux_amd64.tar.gz";
              hash = "sha256-qBa9JrH25vCm3hCdLwzcK9F4nJub65OIHT3IyTKbKYI=";
            };
            sourceRoot = ".";
            nativeBuildInputs = [ prev.autoPatchelfHook ];
            buildInputs = [ prev.stdenv.cc.cc.lib ];
            dontBuild = true;
            installPhase = ''
              runHook preInstall
              install -Dm755 brev $out/bin/brev
              runHook postInstall
            '';
            meta = {
              description = "NVIDIA Brev CLI — launch and manage cloud GPU instances";
              homepage = "https://brev.nvidia.com";
              license = prev.lib.licenses.mit;
              platforms = [ "x86_64-linux" ];
              mainProgram = "brev";
            };
          });
        })
      ];
      environment.systemPackages = with pkgs; [
        claude-code
        codex
        brev-cli
      ];
    };
  };
}
