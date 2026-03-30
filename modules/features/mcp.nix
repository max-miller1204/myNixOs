{ self, inputs, ... }: {
  flake.nixosModules.mcp = { pkgs, lib, config, ... }: {
    options.features.mcp.enable = lib.mkEnableOption "MCP servers for Claude Code and Codex";

    config = lib.mkIf config.features.mcp.enable {

    home-manager.users.${config.my.variables.username} = { config, ... }:
    let
      # ── MCP server definitions (single source of truth) ──────────────
      # Add new MCP servers here. Both Claude and Codex configs are
      # generated from this attrset automatically.
      mcpServers = {
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

      # Generate Codex TOML from the same attrset
      codexMcpToml = lib.concatStringsSep "\n\n" (lib.mapAttrsToList (name: server:
        "[mcp_servers.${name}]\ncommand = \"${server.command}\""
        + lib.optionalString (server.args or [] != [])
          ("\nargs = [${lib.concatMapStringsSep ", " (a: ''"${a}"'') server.args}]")
      ) mcpServers);

      mcpServerNames = builtins.attrNames mcpServers;
    in
    {
      # ── Secrets ──────────────────────────────────────────────────────
      sops.secrets.context7_api_key.sopsFile = ../../secrets/context7.sops.yaml;
      sops.secrets.youtube_api_key.sopsFile = ../../secrets/youtube.sops.yaml;

      # ── MCP launcher scripts ─────────────────────────────────────────
      # These read API keys from sops-nix secrets at runtime.
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

      # ── MCP sync (staging files + activation scripts) ────────────────
      # Staging files written by HM, then merged into mutable configs on activation.
      home.file.".config/claude-code/mcp-servers.json".text =
        builtins.toJSON { inherit mcpServers; };

      home.file.".config/codex/mcp-servers.toml".text = codexMcpToml;

      # Merge MCP servers into ~/.claude.json (Claude owns this file)
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

      # Strip old Nix-managed MCP sections from ~/.codex/config.toml, then append fresh ones
      home.activation.syncCodexMcpServers =
        config.lib.dag.entryAfter [ "writeBoundary" ] ''
          CODEX_DIR="$HOME/.codex"
          CODEX_CONFIG="$CODEX_DIR/config.toml"
          MCP_SOURCE="$HOME/.config/codex/mcp-servers.toml"

          $DRY_RUN_CMD mkdir -p "$CODEX_DIR"

          if [ -f "$CODEX_CONFIG" ]; then
            ${pkgs.gawk}/bin/awk '
              BEGIN { skip = 0 }
              /^\[mcp_servers\.(${lib.concatStringsSep "|" mcpServerNames})\]$/ { skip = 1; next }
              /^\[/ { skip = 0 }
              skip == 0 { print }
            ' "$CODEX_CONFIG" > "$CODEX_CONFIG.tmp"
          else
            : > "$CODEX_CONFIG.tmp"
          fi

          cat "$MCP_SOURCE" >> "$CODEX_CONFIG.tmp"
          $DRY_RUN_CMD mv "$CODEX_CONFIG.tmp" "$CODEX_CONFIG"
        '';
    };
    };
  };
}
