# Keybinds & Shortcuts Reference

Complete shortcut list across all layers: shell, tmux, git, niri window manager.

---

## Shell Aliases

| Alias | Command |
|-------|---------|
| `c` | `claude` |
| `cx` | `clear; claude --dangerously-skip-permissions` |
| `t` | `tmux attach \|\| tmux new -s Work` |
| `g` | `git` |
| `gs` | `git status` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gl` | `git log --oneline` |
| `gcm` | `git commit -m` |
| `gcam` | `git commit -a -m` |
| `gcad` | `git commit -a --amend` |
| `d` | `docker` |
| `ls` | `eza -lh --group-directories-first --icons=auto` |
| `lsa` | `eza -lah --group-directories-first --icons=auto` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `lta` | `eza --tree --level=2 --long --icons --git -a` |
| `ll` | `ls -la` |
| `la` | `ls -a` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `rebuild` | `just switch` |
| `decompress` | `tar -xzf` |

---

## Shell Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `n` | `n [files]` | Open nvim (`.` if no args) |
| `ff` | `ff` | fzf file finder with bat preview |
| `eff` | `eff` | Open fzf-selected file in $EDITOR |
| `sff` | `sff host:/tmp/` | Find recent file via fzf, scp to destination |
| `open` | `open file.pdf` | xdg-open (backgrounded, silenced) |
| `compress` | `compress mydir` | Create mydir.tar.gz |
| `ga` | `ga feature-x` | Create git worktree `../repo--feature-x/`, cd into it |
| `gd` | `gd` | Delete current worktree + branch (gum confirm) |
| `tdl` | `tdl claude` | Tmux dev layout: editor 70% + AI 30% + terminal 15% |
| `tdl` | `tdl claude codex` | Dev layout with two AI panes (split vertically) |
| `tdlm` | `tdlm claude` | Multi-project: one tdl window per subdirectory |
| `tsl` | `tsl 3 claude` | Swarm: 3 tiled panes each running claude |
| `fip` | `fip server 8080 3000` | SSH forward ports to remote host |
| `dip` | `dip 8080 3000` | Disconnect SSH port forwards |
| `lip` | `lip` | List active SSH port forwards |

---

## Git Aliases

| Alias | Command |
|-------|---------|
| `git co` | `git checkout` |
| `git br` | `git branch` |
| `git ci` | `git commit` |
| `git st` | `git status` |
| `git sync` | stash, pull --rebase, pop, restore flake.lock |

---

## Tmux (prefix: Ctrl-a)

### Pane Management

| Key | Action |
|-----|--------|
| `prefix` + `h` | Split horizontal (top/bottom) |
| `prefix` + `v` | Split vertical (left/right) |
| `prefix` + `x` | Kill pane |
| `Ctrl+Alt+Left` | Focus pane left |
| `Ctrl+Alt+Right` | Focus pane right |
| `Ctrl+Alt+Up` | Focus pane up |
| `Ctrl+Alt+Down` | Focus pane down |
| `Ctrl+Alt+Shift+Left` | Resize pane left |
| `Ctrl+Alt+Shift+Right` | Resize pane right |
| `Ctrl+Alt+Shift+Up` | Resize pane up |
| `Ctrl+Alt+Shift+Down` | Resize pane down |

### Window Management

| Key | Action |
|-----|--------|
| `prefix` + `c` | New window |
| `prefix` + `k` | Kill window |
| `prefix` + `r` | Rename window |
| `Alt+1` - `Alt+9` | Switch to window 1-9 |
| `Alt+Left` | Previous window |
| `Alt+Right` | Next window |
| `Alt+Shift+Left` | Swap window left |
| `Alt+Shift+Right` | Swap window right |

### Session Management

| Key | Action |
|-----|--------|
| `prefix` + `C` | New session |
| `prefix` + `K` | Kill session |
| `prefix` + `R` | Rename session |
| `prefix` + `P` | Previous session |
| `prefix` + `N` | Next session |
| `Alt+Up` | Previous session |
| `Alt+Down` | Next session |

### Copy Mode (vi)

| Key | Action |
|-----|--------|
| `prefix` + `[` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection |

### Other

| Key | Action |
|-----|--------|
| `prefix` + `q` | Reload config |

---

## Niri Window Manager (Mod = Super)

### Launching

| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal (Alacritty) |
| `Mod+Space` | App launcher (Noctalia) |
| `Ctrl+Space` | Speech-to-text toggle |
| `Mod+Shift+/` | Show hotkey overlay |

### Window Focus (arrows or hjkl)

| Key | Action |
|-----|--------|
| `Mod+Left/H` | Focus column left |
| `Mod+Right/L` | Focus column right |
| `Mod+Up/K` | Focus window up |
| `Mod+Down/J` | Focus window down |
| `Mod+Home` | Focus first column |
| `Mod+End` | Focus last column |

### Move Windows

| Key | Action |
|-----|--------|
| `Mod+Ctrl+Left/H` | Move column left |
| `Mod+Ctrl+Right/L` | Move column right |
| `Mod+Ctrl+Up/K` | Move window up |
| `Mod+Ctrl+Down/J` | Move window down |
| `Mod+Ctrl+Home` | Move column to first |
| `Mod+Ctrl+End` | Move column to last |

### Monitor Focus

| Key | Action |
|-----|--------|
| `Mod+Shift+Left/H` | Focus monitor left |
| `Mod+Shift+Right/L` | Focus monitor right |
| `Mod+Shift+Up/K` | Focus monitor up |
| `Mod+Shift+Down/J` | Focus monitor down |

### Move to Monitor

| Key | Action |
|-----|--------|
| `Mod+Shift+Ctrl+Left/H` | Move column to monitor left |
| `Mod+Shift+Ctrl+Right/L` | Move column to monitor right |
| `Mod+Shift+Ctrl+Up/K` | Move column to monitor up |
| `Mod+Shift+Ctrl+Down/J` | Move column to monitor down |

### Workspaces

| Key | Action |
|-----|--------|
| `Mod+1` - `Mod+9` | Focus workspace 1-9 |
| `Mod+Ctrl+1` - `Mod+Ctrl+9` | Move column to workspace 1-9 |
| `Mod+Page_Down/U` | Focus workspace down |
| `Mod+Page_Up/I` | Focus workspace up |
| `Mod+Ctrl+Page_Down/U` | Move column to workspace down |
| `Mod+Ctrl+Page_Up/I` | Move column to workspace up |
| `Mod+Shift+Page_Down/U` | Move workspace down |
| `Mod+Shift+Page_Up/I` | Move workspace up |
| `Mod+WheelDown` | Focus workspace down |
| `Mod+WheelUp` | Focus workspace up |

### Window Layout

| Key | Action |
|-----|--------|
| `Mod+Q` | Close window |
| `Ctrl+Alt+Delete` | Quit niri |
| `Mod+R` | Cycle preset column widths |
| `Mod+Shift+R` | Cycle preset window heights |
| `Mod+Ctrl+R` | Reset window height |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+M` | Maximize window to edges |
| `Mod+Ctrl+F` | Expand column to available width |
| `Mod+Minus` | Column width -10% |
| `Mod+Equal` | Column width +10% |
| `Mod+Shift+Minus` | Window height -10% |
| `Mod+Shift+Equal` | Window height +10% |
| `Mod+C` | Center column |
| `Mod+Ctrl+C` | Center all visible columns |

### Floating & Tabs

| Key | Action |
|-----|--------|
| `Mod+V` | Toggle floating |
| `Mod+Shift+V` | Switch focus between floating and tiling |
| `Mod+W` | Toggle tabbed column display |

### Column Grouping

| Key | Action |
|-----|--------|
| `Mod+[` | Consume/expel window left |
| `Mod+]` | Consume/expel window right |
| `Mod+,` | Consume window into column |
| `Mod+.` | Expel window from column |

### Screenshots

| Key | Action |
|-----|--------|
| `Print` | Screenshot (interactive) |
| `Ctrl+Print` | Screenshot current screen |
| `Alt+Print` | Screenshot current window |

### Media & Hardware

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioPrev/Next` | Previous/next track |
| `XF86MonBrightnessUp` | Brightness +10% |
| `XF86MonBrightnessDown` | Brightness -10% |

### System

| Key | Action |
|-----|--------|
| `Mod+Shift+E` | Quit niri |
| `Mod+Shift+P` | Power off monitors |
| `Mod+Escape` | Toggle keyboard shortcuts inhibitor |
| `Super+Alt+S` | Toggle screen reader (Orca) |
