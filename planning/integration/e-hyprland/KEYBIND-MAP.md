# Hyprland keybind map

**Source of truth:** `build_files/etc/skel/.config/hypr/bindings.conf`  
**Modifier:** `$mainMod = SUPER`  
**Layout assumption:** `dwindle` (theme `looknfeel.conf`)

Machine-readable table. Columns: `keys | dispatcher | args | notes`

## Apps

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+Return | exec | ghostty | default terminal |
| SUPER+T | exec | ghostty | same terminal (alt muscle memory) |
| SUPER+E | exec | ghostty -e yazi | file manager |
| SUPER+B | exec | neonwolf | default browser |
| SUPER+A | exec | ghostty -e flatarcade | app store TUI |

## Launcher

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+D | exec | walker | default providers |
| SUPER+Space | exec | walker | same |
| SUPER+R | exec | walker --prefix ">" | runner mode |
| XF86Search | exec | walker | hardware search key |

## Theme

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+T | exec | hyprwave-theme-gui | theme picker GUI |

## Window management

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+Q | killactive | | close focused |
| SUPER+SHIFT+E | exit | | leave Hyprland (Shift required) |
| SUPER+W | togglefloating | | |
| SUPER+F | fullscreen | | |
| SUPER+P | pseudo | | dwindle pseudo |
| SUPER+V | togglegroup | | tab group |
| SUPER+Tab | changegroupactive | f | next in group |
| SUPER+SHIFT+Tab | changegroupactive | b | prev in group |

## Focus

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+Left | movefocus | l | |
| SUPER+Right | movefocus | r | |
| SUPER+Up | movefocus | u | |
| SUPER+Down | movefocus | d | |
| SUPER+H | movefocus | l | vim |
| SUPER+L | movefocus | r | vim |
| SUPER+K | movefocus | u | vim |
| SUPER+J | movefocus | d | vim |

## Move window

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+Left | movewindow | l | |
| SUPER+SHIFT+Right | movewindow | r | |
| SUPER+SHIFT+Up | movewindow | u | |
| SUPER+SHIFT+Down | movewindow | d | |
| SUPER+SHIFT+H | movewindow | l | vim |
| SUPER+SHIFT+L | movewindow | r | vim |
| SUPER+SHIFT+K | movewindow | u | vim |
| SUPER+SHIFT+J | movewindow | d | vim |

## Workspaces

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+1 … SUPER+9 | workspace | 1…9 | |
| SUPER+0 | workspace | 10 | |
| SUPER+SHIFT+1 … SUPER+SHIFT+9 | movetoworkspace | 1…9 | |
| SUPER+SHIFT+0 | movetoworkspace | 10 | |
| SUPER+mouse_down | workspace | e+1 | scroll next |
| SUPER+mouse_up | workspace | e-1 | scroll prev |

## Dwindle split / resize

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+equal | layoutmsg | togglesplit | dwindle only |
| SUPER+minus | splitratio | -0.05 | shrink split |
| SUPER+SHIFT+equal | splitratio | +0.05 | grow split (`+` key) |
| SUPER+ALT+Left | resizeactive | -40 0 | |
| SUPER+ALT+Right | resizeactive | 40 0 | |
| SUPER+ALT+Up | resizeactive | 0 -40 | |
| SUPER+ALT+Down | resizeactive | 0 40 | |
| SUPER+ALT+H/J/K/L | resizeactive | ±40 | vim resize |

## Monitors

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+period | focusmonitor | + | next |
| SUPER+comma | focusmonitor | - | prev |

## Session / tools

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+L | exec | hyprlock | lock screen |
| SUPER+SHIFT+P | exec | hyprpicker -a | color pick → clipboard |

## Screenshots (hyprshot)

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+S | exec | hyprshot -m region --clipboard-only | region → clipboard |
| SUPER+SHIFT+S | exec | hyprshot -m region -o ~/Pictures | region → file |
| SUPER+CTRL+S | exec | hyprshot -m output --clipboard-only | output → clipboard |
| SUPER+CTRL+SHIFT+S | exec | hyprshot -m output -o ~/Pictures | output → file |

## Media / hardware

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| XF86AudioRaiseVolume | exec | wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ | |
| XF86AudioLowerVolume | exec | wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%- | |
| XF86AudioMute | exec | wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle | |
| XF86AudioMicMute | exec | wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle | |
| XF86MonBrightnessUp | exec | brightnessctl s 5%+ | |
| XF86MonBrightnessDown | exec | brightnessctl s 5%- | |
| XF86AudioNext | exec | playerctl next | binde (repeat) |
| XF86AudioPrev | exec | playerctl previous | binde |
| XF86AudioPlay | exec | playerctl play-pause | binde |

## Mouse (bindm)

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+mouse:272 | movewindow | | LMB drag |
| SUPER+mouse:273 | resizewindow | | RMB drag |

## Conflicts / intentional changes (E-W1-001)

| Change | Before | After | Why |
|--------|--------|-------|-----|
| Session exit | SUPER+M | SUPER+SHIFT+E | Fat-finger Super+M killed the session |
| Focus h/l | `layoutmsg setleftwideratio` | `movefocus` | Master-only msg; layout is dwindle |
| Split ratio | setleftwideratio on minus | `splitratio` | Dwindle-compatible |
| Vim move/resize | (missing) | SUPER+SHIFT/ALT + hjkl | Parity with arrows |
| Walker | already bound | unchanged Super+D/Space/R | + explicit exec-once service |

## Walker in-app prefixes (not Hypr binds)

Configured in `walker/config.toml`:

| prefix | provider |
|--------|----------|
| `/` | providerlist |
| `.` | files |
| `:` | symbols |
| `=` | calc |
| `@` | websearch |
| `$` | clipboard |
| `>` | runner (via Super+R) |
