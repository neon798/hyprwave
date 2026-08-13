# Hyprland keybind map (E-W2-001 → E-W4-001)

**Source of truth:** `build_files/etc/skel/.config/hypr/bindings.conf`  
**Modifier:** `$mainMod = SUPER`  
**Layout assumption:** `dwindle` (theme `looknfeel.conf`)  
**Audit:** 2026-08-13 (E-W2-001) — every active `bind`/`binde`/`bindm` line counted (**87** active, **0** commented binds). Map matches skel.

### Lane product tip (E-W4-001 merge-prep)

| Ref | SHA | Notes |
|-----|-----|-------|
| **Product tip** (integrator) | **`d8db11f`** (`d8db11f5ac70922c724db5ef4278404a033a7f83`) | Last `hyprland:` product commit on `lane/e-hyprland` — E-W3-001 SESSION-SMOKE inspect + dwindle comments; includes W2 binds/lock/tooltip work |
| Prior product | `7c1b044` | E-W2-002 lock/idle comments + waybar tooltips |
| Prior product | `e364669` | E-W2-001 assistant bind + float rules + KEYBIND-MAP 87 |
| Bind count | **87** | Unchanged since E-W2-001; W3/W4 were comments/docs only |

Machine-readable table. Columns: `keys | dispatcher | args | notes`

## Apps

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+Return | exec | ghostty | default terminal |
| SUPER+T | exec | ghostty | same terminal (alt muscle memory) |
| SUPER+E | exec | ghostty -e yazi | file manager |
| SUPER+B | exec | neonwolf | default browser |
| SUPER+A | exec | ghostty -e flatarcade | app store TUI (**not** Assistant) |

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
| SUPER+SHIFT+T | exec | hyprwave-theme-gui | theme picker GUI (float `dev.hyprwave.ThemeSwitcher`) |

## Assistant

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+A | exec | ghostty --class=dev.hyprwave.Assistant --title="Hyprwave Assistant" -e hyprwave-assistant | TUI; floats via windowrules; Super+A stays FlatArcade |

## Window management

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+Q | killactive | | close focused |
| SUPER+SHIFT+E | exit | | leave Hyprland (Shift required; Super+M is **not** bound) |
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
| SUPER+H | movefocus | l | vim (lowercase key) |
| SUPER+L | movefocus | r | vim — not the lock bind |
| SUPER+K | movefocus | u | vim |
| SUPER+J | movefocus | d | vim |

## Move window

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+Left | movewindow | l | |
| SUPER+SHIFT+Right | movewindow | r | |
| SUPER+SHIFT+Up | movewindow | u | |
| SUPER+SHIFT+Down | movewindow | d | |
| SUPER+SHIFT+H | movewindow | l | vim lowercase |
| SUPER+SHIFT+L | movewindow | r | vim lowercase `l` — **≠** SUPER+SHIFT+**L** (lock) |
| SUPER+SHIFT+K | movewindow | u | vim |
| SUPER+SHIFT+J | movewindow | d | vim |

## Workspaces

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+1 | workspace | 1 | |
| SUPER+2 | workspace | 2 | |
| SUPER+3 | workspace | 3 | |
| SUPER+4 | workspace | 4 | |
| SUPER+5 | workspace | 5 | |
| SUPER+6 | workspace | 6 | |
| SUPER+7 | workspace | 7 | |
| SUPER+8 | workspace | 8 | |
| SUPER+9 | workspace | 9 | |
| SUPER+0 | workspace | 10 | |
| SUPER+SHIFT+1 | movetoworkspace | 1 | |
| SUPER+SHIFT+2 | movetoworkspace | 2 | |
| SUPER+SHIFT+3 | movetoworkspace | 3 | |
| SUPER+SHIFT+4 | movetoworkspace | 4 | |
| SUPER+SHIFT+5 | movetoworkspace | 5 | |
| SUPER+SHIFT+6 | movetoworkspace | 6 | |
| SUPER+SHIFT+7 | movetoworkspace | 7 | |
| SUPER+SHIFT+8 | movetoworkspace | 8 | |
| SUPER+SHIFT+9 | movetoworkspace | 9 | |
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
| SUPER+ALT+H | resizeactive | -40 0 | vim |
| SUPER+ALT+L | resizeactive | 40 0 | vim |
| SUPER+ALT+K | resizeactive | 0 -40 | vim |
| SUPER+ALT+J | resizeactive | 0 40 | vim |

## Monitors

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+period | focusmonitor | + | next |
| SUPER+comma | focusmonitor | - | prev |

## Session / tools

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+SHIFT+L | exec | loginctl lock-session | uppercase **L** → hypridle `lock_cmd` = `pidof hyprlock \|\| hyprlock` (no direct hyprlock bind) |
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
| XF86AudioRaiseVolume | exec | wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ | bind |
| XF86AudioLowerVolume | exec | wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%- | bind |
| XF86AudioMute | exec | wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle | bind |
| XF86AudioMicMute | exec | wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle | bind |
| XF86MonBrightnessUp | exec | brightnessctl s 5%+ | bind |
| XF86MonBrightnessDown | exec | brightnessctl s 5%- | bind |
| XF86AudioNext | exec | playerctl next | **binde** (repeat) |
| XF86AudioPrev | exec | playerctl previous | **binde** |
| XF86AudioPlay | exec | playerctl play-pause | **binde** |

## Mouse (bindm)

| keys | dispatcher | args | notes |
|------|------------|------|-------|
| SUPER+mouse:272 | movewindow | | LMB drag |
| SUPER+mouse:273 | resizewindow | | RMB drag |

## Intentional absences

| keys | why not bound |
|------|----------------|
| SUPER+M | formerly exit; removed — fat-finger risk; exit is SUPER+SHIFT+E |
| wofi / rofi / dmenu / cliphist | not shipped; Walker + elephant (+ wl-clipboard) |
| swaybg | wallpaper is hyprpaper |

## Walker in-app prefixes (not Hypr binds)

Configured in `walker/config.toml`:

| prefix | provider |
|--------|----------|
| `/` | providerlist |
| `.` | files |
| `:` | symbols |
| `=` | calc |
| `@` | websearch |
| `$` | clipboard (elephant-clipboard; no cliphist daemon) |
| `>` | runner (via Super+R) |

## Change log

| Wave | Change | Why |
|------|--------|-----|
| E-W1-001 | exit SUPER+SHIFT+E; dwindle binds; Walker exec-once | first session |
| E-W1-002 | lock via loginctl; idle lock before DPMS | security / single hyprlock |
| E-W1-003 | reserved SUPER+SHIFT+A (comment); windowrule/hyprpaper docs | C HANDOFF |
| E-W1-004 | map/smoke freeze | pre-merge gate |
| E-W2-001 | **active** SUPER+SHIFT+A with Ghostty `--class=dev.hyprwave.Assistant`; float rules for assistant + theme-gui size | day-1 UX; assistant ships in image |
| E-W2-002 | lock/idle comment hygiene; waybar tooltips name nm-connection-editor / pavucontrol / blueman-manager | no redesign; copy only |
