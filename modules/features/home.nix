{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }: {
    options.features.homeManager.enable = lib.mkEnableOption "Home Manager for primary user";

    imports = [ inputs.home-manager.nixosModules.home-manager ];

    config = lib.mkIf config.features.homeManager.enable {

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";

    home-manager.users.${config.my.variables.username} = { config, ... }:
    let
      claudeMcpServers = {
        nixos = {
          command = "nix";
          args = [ "run" "github:utensils/mcp-nixos" "--" ];
          type = "stdio";
        };
        context7 = {
          command = "${config.home.homeDirectory}/.claude/run-context7.sh";
          args = [ ];
          type = "stdio";
        };
        youtube = {
          command = "${config.home.homeDirectory}/.claude/run-youtube.sh";
          args = [ ];
          type = "stdio";
        };
      };
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      home.stateVersion = "25.11";

      xdg.mimeApps.enable = true;

      # SOPS secrets (Home Manager level)
      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      sops.secrets.context7_api_key = {
        sopsFile = ../../secrets/context7.sops.yaml;
      };
      sops.secrets.youtube_api_key = {
        sopsFile = ../../secrets/youtube.sops.yaml;
      };

      # Claude Code config
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/nix/SKILL.md".source = ./claude/skills/nix/SKILL.md;

      # Context7 MCP launcher — reads API key from HM sops-nix secret at runtime
      home.file.".claude/run-context7.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          secret_file="${config.sops.secrets.context7_api_key.path}"
          if [[ ! -r "$secret_file" ]]; then
            echo "Missing context7 key at $secret_file" >&2
            echo "Check sops-nix HM activation." >&2
            exit 1
          fi

          export CONTEXT7_API_KEY="$(tr -d '\n' < "$secret_file")"
          exec nix shell nixpkgs#nodejs --command npx -y @upstash/context7-mcp "$@"
        '';
      };

      # YouTube MCP launcher — reads API key from HM sops-nix secret at runtime
      home.file.".claude/run-youtube.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          secret_file="${config.sops.secrets.youtube_api_key.path}"
          if [[ ! -r "$secret_file" ]]; then
            echo "Missing YouTube API key at $secret_file" >&2
            echo "Check sops-nix HM activation." >&2
            exit 1
          fi

          export YOUTUBE_API_KEY="$(tr -d '\n' < "$secret_file")"
          exec ${inputs.youtube-mcp-server.packages.${pkgs.stdenv.hostPlatform.system}.youtube-mcp-server}/bin/zubeid-youtube-mcp-server "$@"
        '';
      };

      # Declarative MCP server definitions — merged into ~/.claude.json on rebuild
      home.file.".config/claude-code/mcp-servers.json".text =
        builtins.toJSON { mcpServers = claudeMcpServers; };

      home.activation.syncClaudeMcpServers =
        config.lib.dag.entryAfter [ "writeBoundary" ] ''
          CLAUDE_JSON="$HOME/.claude.json"
          MCP_SOURCE="$HOME/.config/claude-code/mcp-servers.json"

          if [ ! -f "$CLAUDE_JSON" ]; then
            $DRY_RUN_CMD cp "$MCP_SOURCE" "$CLAUDE_JSON"
          elif ${pkgs.jq}/bin/jq empty "$CLAUDE_JSON" 2>/dev/null; then
            $DRY_RUN_CMD ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$CLAUDE_JSON" "$MCP_SOURCE" \
              > "$CLAUDE_JSON.tmp" && $DRY_RUN_CMD mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
          fi
        '';
    };
    };
  };
}
