if hash setxkbmap 2>/dev/null; then
    setxkbmap pl -option caps:escape
    setxkbmap pl -option altwin:swap_lalt_lwin
    # disable crtl+alt+F-x combos
    setxkbmap -option srvrkeys:none
fi
