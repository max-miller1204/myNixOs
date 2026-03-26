{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, config, ... }: {
    options.features.homeManager.enable = lib.mkEnableOption "Home Manager for user max";

    imports = [ inputs.home-manager.nixosModules.home-manager ];

    config = lib.mkIf config.features.homeManager.enable {

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";

    home-manager.users.max = { config, ... }:
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
      home.stateVersion = "25.11";

      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      # Claude Code config
      home.file.".claude/settings.json".source = ./claude/settings.json;
      home.file.".claude/statusline.sh" = {
        source = ./claude/statusline.sh;
        executable = true;
      };
      home.file.".claude/skills/nix/SKILL.md".source = ./claude/skills/nix/SKILL.md;

      # Context7 MCP launcher — reads API key from sops-nix secret at runtime
      home.file.".claude/run-context7.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          secret_file="/run/secrets/context7_api_key"
          if [[ ! -r "$secret_file" ]]; then
            echo "Missing context7 key at $secret_file" >&2
            echo "Create secrets/context7.sops.yaml and rebuild." >&2
            exit 1
          fi

          export CONTEXT7_API_KEY="$(tr -d '\n' < "$secret_file")"
          exec nix shell nixpkgs#nodejs --command npx -y @upstash/context7-mcp "$@"
        '';
      };

      # YouTube MCP launcher — reads API key from sops-nix secret at runtime
      home.file.".claude/run-youtube.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          secret_file="/run/secrets/youtube_api_key"
          if [[ ! -r "$secret_file" ]]; then
            echo "Missing YouTube API key at $secret_file" >&2
            echo "Create secrets/youtube.sops.yaml and rebuild." >&2
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
