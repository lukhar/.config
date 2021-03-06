if hash setxkbmap 2>/dev/null; then
    setxkbmap pl -option caps:escape
    setxkbmap pl -option altwin:swap_lalt_lwin
    # disable crtl+alt+F-x combos
    # setxkbmap -option srvrkeys:none

    # use F13 as PrintScr
    # setxkbmap -option "apple:alupckeys"
fi

export TERMINAL=/bin/alacritty
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CURRENT_DESKTOP=XFCE
export XDG_CONFIG_DIRS=/etc/xdg%  

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
