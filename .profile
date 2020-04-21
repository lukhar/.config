if hash setxkbmap 2>/dev/null; then
    setxkbmap pl -option caps:escape
    # setxkbmap pl -option altwin:swap_lalt_lwin
    # disable crtl+alt+F-x combos
    setxkbmap -option srvrkeys:none
fi

export EDITOR=/usr/bin/nvim
export TERMINAL=/usr/bin/lxterminal
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export XDG_CURRENT_DESKTOP=XFCE
export XDG_CONFIG_DIRS=/etc/xdg%  
