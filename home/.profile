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
[ -f "$HOME/.config/shell/xdg.sh" ] && . "$HOME/.config/shell/xdg.sh"
# Portals choose their backend from this, so it has to match the running
# compositor: XFCE alongside awesome on piecyk, Hyprland on the new laptop.
case "${HOSTNAME%%.*}" in
  piecyk) export XDG_CURRENT_DESKTOP=XFCE ;;
  *)      [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && export XDG_CURRENT_DESKTOP=Hyprland ;;
esac
export XDG_CONFIG_DIRS=/etc/xdg

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
