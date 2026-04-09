{ ... }: {
  den.aspects.nix-utils = {
    nixos = { pkgs, lib, ... }:
    let
      nsymlink = pkgs.writeShellApplication {
        name = "nsymlink";
        text = ''
          if [ "$#" -eq 0 ]; then
              echo "No file(s) specified."
              exit 1
          fi

          for file in "$@"; do
            if [[ "$file" == *.bak ]]; then
                continue
            fi

            if [ -L "$file" ]; then
                mv "$file" "$file.bak"
                cp -L "$file.bak" "$file"
                chmod +w "$file"

            # regular file, reverse the process
            elif [ -f "$file" ] && [ -L "$file.bak" ]; then
                mv "$file.bak" "$file"
            fi
          done
        '';
      };

      ngeneration = pkgs.writeShellApplication {
        name = "ngeneration";
        text = ''
          curr=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')

          if [ "$#" -eq 0 ]; then
            echo "$curr"
          else
            if [[ -f "/nix/var/nix/profiles/system-$1-link/bin/switch-to-configuration" ]]; then
              sudo "/nix/var/nix/profiles/system-$1-link/bin/switch-to-configuration" boot
            else
              target="/nix/var/nix/profiles/system-$((curr + $1))-link/bin/switch-to-configuration"
              if [[ -f "$target" ]]; then
                sudo "$target" boot
              else
                echo "No generation $((curr + $1)) found."
                exit 1
              fi
            fi
          fi
        '';
      };

      ngeneration-completions = pkgs.writeTextFile {
        name = "ngeneration-completions";
        destination = "/share/fish/vendor_completions.d/ngeneration.fish";
        text = ''
          function _ngeneration
              set -l profile_dir "/nix/var/nix/profiles"
              command ls -1 "$profile_dir" | \
                string match -r '^system-([0-9]+)-link$' | \
                string replace -r '^system-([0-9]+)-link$' '$1' | \
                sort -ru
          end

          complete --keep-order -c ngeneration -f -a "(_ngeneration)"
        '';
      };

      print-config-commands = lib.mapAttrsToList (prog: cmd:
        pkgs.writeShellApplication {
          name = "${prog}-config";
          runtimeInputs = [ pkgs.bat ];
          text = cmd;
        }
      ) {
        niri = ''bat --language=kdl ~/.config/niri/config.kdl'';
        ghostty = ''bat ~/.config/ghostty/config'';
        noctalia = ''bat --language=json ~/.config/noctalia/settings.json'';
        fish = ''bat ~/.config/fish/config.fish'';
        tmux = ''bat ~/.config/tmux/tmux.conf'';
        starship = ''bat --language=toml ~/.config/starship.toml'';
      };
    in {
      environment.systemPackages = [
        nsymlink
        ngeneration
        ngeneration-completions
      ] ++ print-config-commands;
    };
  };
}
