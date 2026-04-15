{ self, inputs, ... }: {
  den.aspects.shell = {
    homeManager = { pkgs, ... }:
    let
      fish-completion-sync = pkgs.fetchFromGitHub {
        owner = "iynaix";
        repo = "fish-completion-sync";
        rev = "4f058ad2986727a5f510e757bc82cbbfca4596f0";
        hash = "sha256-kHpdCQdYcpvi9EFM/uZXv93mZqlk1zCi2DRhWaDyK5g=";
      };
    in {
      programs.fish = {
        enable = true;
        plugins = [ { name = "fish-completion-sync"; src = fish-completion-sync; } ];
        interactiveShellInit = ''
          if test (uname) = Darwin
            fish_add_path --prepend /opt/homebrew/bin
            mise activate fish | source
          end
          fish_add_path --prepend ~/.bun/bin
          if set -q NIX_LD_LIBRARY_PATH
            set -gx LD_LIBRARY_PATH $NIX_LD_LIBRARY_PATH
          end
          set -g fish_greeting
          pfetch
          set -gx BAT_THEME ansi
          set -gx EDITOR nvim
          set -gx VISUAL nvim

          # Reload completions when $XDG_DATA_DIRS changes (e.g. nix shell)
          source ${fish-completion-sync}/init.fish
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
          c = "claude --plugin-dir ~/.claude/plugins/lsp-servers";
          cx = "clear; claude --dangerously-skip-permissions --plugin-dir ~/.claude/plugins/lsp-servers";
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
          gwr = ''
            set -l common_dir (git rev-parse --git-common-dir 2>/dev/null); or begin
              echo "gwr: not inside a git repository" >&2
              return 1
            end
            set -l repo_root (realpath "$common_dir/..")

            set -l target_path ""
            set -l target_branch ""
            set -l self_mode false

            if test (count $argv) -gt 0
              set target_branch $argv[1]
              set -l base (basename $repo_root)
              set -l parent (dirname $repo_root)
              set target_path "$parent/$base--$target_branch"
              if not test -d $target_path
                echo "gwr: no worktree found at $target_path" >&2
                return 1
              end
            else
              set -l git_dir (git rev-parse --git-dir 2>/dev/null); or return 1
              set -l resolved_git_dir (realpath $git_dir)
              set -l resolved_common_dir (realpath $common_dir)
              if test "$resolved_git_dir" = "$resolved_common_dir"
                echo "gwr: current directory is the main worktree; pass a branch name to remove a worktree" >&2
                return 1
              end
              set target_path (pwd)
              set target_branch (git branch --show-current 2>/dev/null); or return 1
              set self_mode true
            end

            if not gum confirm "Remove worktree '$target_path' and branch '$target_branch'?"
              return 1
            end

            set -l self_pane ""
            set -l other_panes
            if test -n "$TMUX"
              if test "$self_mode" = true
                set self_pane $TMUX_PANE
              else
                for line in (tmux list-panes -a -F "#{pane_id} #{pane_current_path}")
                  set -l parts (string split -m 1 " " -- $line)
                  set -l pid $parts[1]
                  set -l ppath $parts[2]
                  if test "$ppath" = "$target_path"; or string match -q "$target_path/*" -- $ppath
                    set -a other_panes $pid
                  end
                end
              end
            end

            cd $repo_root; or return 1
            git worktree remove $target_path --force; or return 1
            git branch -D $target_branch

            for pid in $other_panes
              tmux kill-pane -t $pid 2>/dev/null
            end
            if test -n "$self_pane"
              tmux kill-pane -t $self_pane 2>/dev/null
            end
          '';
          gwra = ''
            set -l common_dir (git rev-parse --git-common-dir 2>/dev/null); or begin
              echo "gwra: not inside a git repository" >&2
              return 1
            end
            set -l main_abs (realpath "$common_dir/..")
            set -l base (basename $main_abs)
            set -l parent (dirname $main_abs)
            set -l prefix "$parent/$base--"

            set -l targets
            set -l target_branches
            set -l current_path ""
            set -l current_branch ""
            for line in (git -C $main_abs worktree list --porcelain)
              if string match -q "worktree *" -- $line
                set current_path (string replace "worktree " "" -- $line)
              else if string match -q "branch refs/heads/*" -- $line
                set current_branch (string replace "branch refs/heads/" "" -- $line)
                if string match -q "$prefix*" -- $current_path
                  set -a targets $current_path
                  set -a target_branches $current_branch
                end
                set current_path ""
                set current_branch ""
              end
            end

            if test (count $targets) -eq 0
              echo "gwra: no swarm worktrees to remove"
              return 0
            end

            echo "Will remove:"
            for i in (seq (count $targets))
              echo "  $targets[$i]  ($target_branches[$i])"
            end
            if not gum confirm "Remove all listed worktrees and branches?"
              return 1
            end

            cd $main_abs; or return 1

            set -l self_pane ""
            if test -n "$TMUX"
              set self_pane $TMUX_PANE
              for line in (tmux list-panes -a -F "#{pane_id} #{pane_current_path}")
                set -l parts (string split -m 1 " " -- $line)
                set -l pid $parts[1]
                set -l ppath $parts[2]
                if test "$pid" = "$self_pane"
                  continue
                end
                for t in $targets
                  if test "$ppath" = "$t"; or string match -q "$t/*" -- $ppath
                    tmux kill-pane -t $pid 2>/dev/null
                    break
                  end
                end
              end
            end

            for i in (seq (count $targets))
              git worktree remove --force $targets[$i]
              git branch -D $target_branches[$i]
            end

            if test -n "$self_pane"
              tmux kill-pane -t $self_pane 2>/dev/null
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
          tslw = ''
            if test (count $argv) -lt 2
              echo "Usage: tslw <cmd> <branch1> [branch2 ...]"
              echo "  Pass \"\" as cmd to skip auto-running anything."
              return 1
            end
            if test -z "$TMUX"
              echo "You must start tmux to use tslw."
              return 1
            end
            set -l cmd $argv[1]
            set -l branches $argv[2..-1]

            set -l common_dir (git rev-parse --git-common-dir 2>/dev/null); or begin
              echo "tslw: not inside a git repository" >&2
              return 1
            end
            set -l main_abs (realpath "$common_dir/..")
            set -l base (basename $main_abs)
            set -l parent (dirname $main_abs)

            set -l wt_paths
            for branch in $branches
              set -l wt_path "$parent/$base--$branch"
              if not test -d $wt_path
                git -C $main_abs worktree add -b $branch $wt_path 2>/dev/null
                or git -C $main_abs worktree add $wt_path $branch
                or begin
                  echo "tslw: failed to create worktree for $branch" >&2
                  return 1
                end
              end
              set -a wt_paths $wt_path
            end

            set -l new_panes
            set -l split_target $TMUX_PANE
            for wt in $wt_paths
              set -l new_pane (tmux split-window -h -t $split_target -c $wt -P -F "#{pane_id}")
              set -a new_panes $new_pane
              set split_target $new_pane
              tmux select-layout -t $TMUX_PANE tiled
            end
            if test -n "$cmd"
              for pane in $new_panes
                tmux send-keys -t $pane $cmd C-m
              end
            end
            tmux select-pane -t $new_panes[1]
          '';
          tslwm = ''
            if test (count $argv) -lt 2
              echo "Usage: tslwm <cmd> <branch1> [branch2 ...]"
              return 1
            end
            if test -z "$TMUX"
              echo "You must start tmux to use tslwm."
              return 1
            end
            set -l cmd $argv[1]
            set -l branches $argv[2..-1]

            set -l common_dir (git rev-parse --git-common-dir 2>/dev/null); or begin
              echo "tslwm: not inside a git repository" >&2
              return 1
            end
            set -l main_abs (realpath "$common_dir/..")
            set -l base (basename $main_abs)
            set -l parent (dirname $main_abs)

            for branch in $branches
              set -l wt_path "$parent/$base--$branch"
              if not test -d $wt_path
                git -C $main_abs worktree add -b $branch $wt_path 2>/dev/null
                or git -C $main_abs worktree add $wt_path $branch
                or begin
                  echo "tslwm: failed to create worktree for $branch" >&2
                  continue
                end
              end
              set -l new_win (tmux new-window -c $wt_path -n $branch -P -F "#{pane_id}")
              if test -n "$cmd"
                tmux send-keys -t $new_win $cmd C-m
              end
            end
          '';
          gwf = ''
            set -l common_dir (realpath (git rev-parse --git-common-dir 2>/dev/null)); or begin
              echo "gwf: not inside a git repository" >&2
              return 1
            end
            set -l main_abs (realpath "$common_dir/..")

            set -l source_abs ""
            set -l branch ""
            set -l self_mode false

            if test (count $argv) -gt 0
              set branch $argv[1]
              set -l base (basename $main_abs)
              set -l parent (dirname $main_abs)
              set source_abs "$parent/$base--$branch"
              if not test -d $source_abs
                echo "gwf: no worktree found at $source_abs" >&2
                return 1
              end
            else
              set -l git_dir (git rev-parse --git-dir 2>/dev/null); or return 1
              set -l resolved_git_dir (realpath $git_dir)
              if test "$resolved_git_dir" = "$common_dir"
                echo "gwf: already in the main worktree; pass a branch name to fold a worktree" >&2
                return 1
              end
              set branch (git branch --show-current 2>/dev/null); or return 1
              set source_abs (pwd -P)
              set self_mode true
            end

            if not gum confirm "Apply '$branch' to main, stage, remove worktree, and close pane?"
              return 1
            end

            set -l has_tracked (git -C $source_abs diff HEAD --name-only; git -C $source_abs diff --cached --name-only)
            set -l untracked (git -C $source_abs ls-files --others --exclude-standard)

            if test -n "$has_tracked"
              git -C $source_abs diff HEAD | git -C $main_abs apply --index - 2>/dev/null
              or git -C $source_abs diff HEAD | git -C $main_abs apply --3way -
            end

            for f in $untracked
              mkdir -p (dirname "$main_abs/$f")
              cp "$source_abs/$f" "$main_abs/$f"
            end

            git -C $main_abs add .
            git -C $main_abs status --short
            echo "Applied and staged in $main_abs"

            set -l self_pane ""
            set -l other_panes
            if test -n "$TMUX"
              if test "$self_mode" = true
                set self_pane $TMUX_PANE
              else
                for line in (tmux list-panes -a -F "#{pane_id} #{pane_current_path}")
                  set -l parts (string split -m 1 " " -- $line)
                  set -l pid $parts[1]
                  set -l ppath $parts[2]
                  if test "$ppath" = "$source_abs"; or string match -q "$source_abs/*" -- $ppath
                    set -a other_panes $pid
                  end
                end
              end
            end

            cd $main_abs; or return 1
            git worktree remove $source_abs --force; or return 1
            git branch -D $branch

            for pid in $other_panes
              tmux kill-pane -t $pid 2>/dev/null
            end
            if test -n "$self_pane"
              tmux kill-pane -t $self_pane 2>/dev/null
            end
          '';
          gwa = ''
            set -l common_dir (realpath (git rev-parse --git-common-dir 2>/dev/null)); or begin
              echo "gwa: not inside a git repository" >&2
              return 1
            end
            set -l main_abs (realpath "$common_dir/..")

            set -l source_abs ""
            if test (count $argv) -gt 0
              set -l branch $argv[1]
              set -l base (basename $main_abs)
              set -l parent (dirname $main_abs)
              set source_abs "$parent/$base--$branch"
              if not test -d $source_abs
                echo "gwa: no worktree found at $source_abs" >&2
                return 1
              end
            else
              set -l git_dir (git rev-parse --git-dir 2>/dev/null); or return 1
              set -l resolved_git_dir (realpath $git_dir)
              if test "$resolved_git_dir" = "$common_dir"
                echo "gwa: already in the main worktree; pass a branch name to apply a worktree" >&2
                return 1
              end
              set source_abs (pwd -P)
            end

            set -l has_tracked (git -C $source_abs diff HEAD --name-only; git -C $source_abs diff --cached --name-only)
            set -l untracked (git -C $source_abs ls-files --others --exclude-standard)

            if test -z "$has_tracked" -a -z "$untracked"
              echo "Nothing to apply."
              return 0
            end

            if test -n "$has_tracked"
              git -C $source_abs diff HEAD | git -C $main_abs apply --index - 2>/dev/null
              or git -C $source_abs diff HEAD | git -C $main_abs apply --3way -
            end

            for f in $untracked
              mkdir -p (dirname "$main_abs/$f")
              cp "$source_abs/$f" "$main_abs/$f"
            end

            git -C $main_abs status --short
            echo "Applied to $main_abs"
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
            if test (uname) = Linux
              xdg-open $argv >/dev/null 2>&1 &
              disown
            else
              command open $argv
            end
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
