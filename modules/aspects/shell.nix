{ self, inputs, ... }: {
  den.aspects.shell = {
    homeManager = { ... }: {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          fish_add_path --prepend /opt/homebrew/bin
          if set -q NIX_LD_LIBRARY_PATH
            set -gx LD_LIBRARY_PATH $NIX_LD_LIBRARY_PATH
          end
          set -g fish_greeting
          pfetch
          set -gx BAT_THEME ansi
        '';
        shellAliases = {
          ll = "ls -la";
          la = "ls -a";
          gs = "git status";
          gc = "git commit";
          gp = "git push";
          gl = "git log --oneline";
          rebuild = "just switch";
          tmux-help = "bat ~/.config/tmux/cheatsheet.md";
          c = "claude";
          cx = "clear; claude --dangerously-skip-permissions";
          t = "tmux attach || tmux new -s Work";
          g = "git";
          gcm = "git commit -m";
          gcam = "git commit -a -m";
          gcad = "git commit -a --amend";
          d = "docker";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          ls = "eza -lh --group-directories-first --icons=auto";
          lsa = "eza -lah --group-directories-first --icons=auto";
          lt = "eza --tree --level=2 --long --icons --git";
          lta = "eza --tree --level=2 --long --icons --git -a";
          decompress = "tar -xzf";
        };
        functions = {
          ga = ''
            if test -z "$argv[1]"
              echo "Usage: ga [branch name]"
              return 1
            end
            set -l branch $argv[1]
            set -l base (basename $PWD)
            set -l wt_path "../$base--$branch"
            git worktree add -b $branch $wt_path
            cd $wt_path
          '';
          gd = ''
            if gum confirm "Remove worktree and branch?"
              set -l cwd (pwd)
              set -l wt (basename $cwd)
              set -l root (string replace -r '--.*' "" $wt)
              set -l branch (string replace -r '^[^-]*--' "" $wt)
              if test "$root" != "$wt"
                cd "../$root"
                git worktree remove $cwd --force; or return 1
                git branch -D $branch
              end
            end
          '';
          tdl = ''
            if test -z "$argv[1]"
              echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"
              return 1
            end
            if test -z "$TMUX"
              echo "You must start tmux to use tdl."
              return 1
            end
            set -l current_dir $PWD
            set -l ai $argv[1]
            set -l ai2 $argv[2]
            set -l editor_pane $TMUX_PANE
            tmux rename-window -t $editor_pane (basename $current_dir)
            tmux split-window -v -p 15 -t $editor_pane -c $current_dir
            set -l ai_pane (tmux split-window -h -p 30 -t $editor_pane -c $current_dir -P -F "#{pane_id}")
            if test -n "$ai2"
              set -l ai2_pane (tmux split-window -v -t $ai_pane -c $current_dir -P -F "#{pane_id}")
              tmux send-keys -t $ai2_pane $ai2 C-m
            end
            tmux send-keys -t $ai_pane $ai C-m
            tmux send-keys -t $editor_pane "$EDITOR ." C-m
            tmux select-pane -t $editor_pane
          '';
          tdlm = ''
            if test -z "$argv[1]"
              echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"
              return 1
            end
            if test -z "$TMUX"
              echo "You must start tmux to use tdlm."
              return 1
            end
            set -l ai $argv[1]
            set -l ai2 $argv[2]
            set -l base_dir $PWD
            set -l first true
            tmux rename-session (basename $base_dir | tr ".:" "--")
            for dir in $base_dir/*/
              test -d $dir; or continue
              set -l dirpath (string trim -r -c "/" $dir)
              if test $first = true
                tmux send-keys -t $TMUX_PANE "cd '$dirpath' && tdl $ai $ai2" C-m
                set first false
              else
                set -l pane_id (tmux new-window -c $dirpath -P -F "#{pane_id}")
                tmux send-keys -t $pane_id "tdl $ai $ai2" C-m
              end
            end
          '';
          tsl = ''
            if test -z "$argv[1]"; or test -z "$argv[2]"
              echo "Usage: tsl <pane_count> <command>"
              return 1
            end
            if test -z "$TMUX"
              echo "You must start tmux to use tsl."
              return 1
            end
            set -l count $argv[1]
            set -l cmd $argv[2]
            set -l current_dir $PWD
            set -l panes $TMUX_PANE
            tmux rename-window -t $TMUX_PANE (basename $current_dir)
            while test (count $panes) -lt $count
              set -l split_target $panes[-1]
              set -l new_pane (tmux split-window -h -t $split_target -c $current_dir -P -F "#{pane_id}")
              set -a panes $new_pane
              tmux select-layout -t $panes[1] tiled
            end
            for pane in $panes
              tmux send-keys -t $pane $cmd C-m
            end
            tmux select-pane -t $panes[1]
          '';
          n = ''
            if test (count $argv) -eq 0
              command nvim .
            else
              command nvim $argv
            end
          '';
          compress = ''
            if test -z "$argv[1]"
              echo "Usage: compress <directory>"
              return 1
            end
            set -l target (string trim -r -c "/" $argv[1])
            tar -czf "$target.tar.gz" $target
          '';
          ff = ''
            fzf --preview 'bat --style=numbers --color=always {}'
          '';
          eff = ''
            set -l file (ff)
            if test -n "$file"
              $EDITOR $file
            end
          '';
          sff = ''
            if test (count $argv) -eq 0
              echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
              return 1
            end
            set -l file (find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | fzf --preview 'bat --style=numbers --color=always {}')
            if test -n "$file"
              scp $file $argv[1]
            end
          '';
          open = ''
            xdg-open $argv >/dev/null 2>&1 &
            disown
          '';
          fip = ''
            if test (count $argv) -lt 2
              echo "Usage: fip <host> <port1> [port2] ..."
              return 1
            end
            set -l host $argv[1]
            for port in $argv[2..]
              ssh -f -N -L "$port:localhost:$port" $host; and echo "Forwarding localhost:$port -> $host:$port"
            end
          '';
          dip = ''
            if test (count $argv) -eq 0
              echo "Usage: dip <port1> [port2] ..."
              return 1
            end
            for port in $argv
              pkill -f "ssh.*-L $port:localhost:$port"; and echo "Stopped forwarding port $port"; or echo "No forwarding on port $port"
            end
          '';
          lip = ''
            pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+"
            or echo "No active forwards"
          '';
        };
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.atuin = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          auto_sync = false;
          update_check = false;
          style = "compact";
          inline_height = 10;
        };
      };

      programs.bat.enable = true;
      programs.fzf.enable = true;
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
