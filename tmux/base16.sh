# Base16 Styling Guidelines:

base00=default   # - Default
base01='#151515' # - Lighter Background (Used for status bars)
base02='#202020' # - Selection Background
base03='#303030' # - Comments, Invisibles, Line Highlighting
base04='#505050' # - Dark Foreground (Used for status bars)
base05='#D0D0D0' # - Default Foreground, Caret, Delimiters, Operators
base06='#E0E0E0' # - Light Foreground (Not often used)
base07='#F5F5F5' # - Light Background (Not often used)
base08='#AC4142' # - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
base09='#D28445' # - Integers, Boolean, Constants, XML Attributes, Markup Link Url
base0A='#F4BF75' # - Classes, Markup Bold, Search Text Background
base0B='#90A959' # - Strings, Inherited Class, Markup Code, Diff Inserted
base0C='#75B5AA' # - Support, Regular Expressions, Escape Characters, Markup Quotes
base0D='#6A9FB5' # - Functions, Methods, Attribute IDs, Headings
base0E='#AA759F' # - Keywords, Storage, Selector, Markup Italic, Diff Changed
base0F='#8F5536' # - Deprecated, Opening/Closing Embedded Language Tags, e.g. <? php ?>

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5

# default statusbar colors
# set-option -g status-style fg=$base02,bg=$base00,default
set-option -g status-style "fg=#545c7e bg=#1f2335"

set-window-option -g window-status-style fg=$base00,bg=$base00
set -g window-status-format " #I #W"

# active window title colors
set-window-option -g window-status-current-style fg=$base0C,bg=$base00
set-window-option -g  window-status-current-format " #[bold]#W "

# pane border colors
set-window-option -g pane-border-style fg=$base03
set-window-option -g pane-active-border-style fg=$base0C

# message text
set-option -g message-style fg=$base0C,bg=$base00

# pane number display
set-option -g display-panes-active-colour $base0C
set-option -g display-panes-colour $base01

# clock
set-window-option -g clock-mode-colour $base0C

tm_session_name="#[default,bg=$base00,fg=$base0E] #S "
set -g status-left "👽 $tm_session_name"

tm_date="#[default,bg=$base00,fg=$base0C]  %d/%m/%Y 󰥔 %H:%M"
tm_host="#[fg=$base0E,bg=$base00]  #h "
tm_battery="#[fg=$base0F,bg=$base00] ♥ #(pmset -g batt | awk '{print $3}' | sed 's/;//' | tail -n+2)"
tm_spotify="#[fg=$base0A,bg=$base00]   #{spotify_status_full}"
tm_cpu="#[fg=$base0F,bg=$base00]󰻠 #{cpu_percentage} CPU | 󰍛 #{ram_percentage} RAM"

# OSX
# set -g status-right "$tm_battery $tm_date $tm_host"

# Linux
set -g status-right "$tm_spotify $tm_cpu $tm_date $tm_host"
