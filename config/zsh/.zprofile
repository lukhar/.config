# Setting ZDOTDIR makes ~/.zprofile inert, so the login-shell setup moved here.
# Guarded throughout so the same file is safe on piecyk, where none of it exists.

# `brew shellenv` is a subprocess costing ~58ms to print eight lines of static
# text -- 39% of the time to open a tmux pane. The guard already hardcodes the
# prefix, so there was never anything to discover; these are its exact contents
# for /opt/homebrew. Re-derive with `brew shellenv` if the prefix ever moves.
[ -x /opt/homebrew/bin/brew ] && {
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  fpath[1,0]="/opt/homebrew/share/zsh/site-functions"
  export FPATH
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
  [ -z "${MANPATH-}" ] || { export MANPATH="${MANPATH%"${MANPATH##*[!:]}"}"; export MANPATH=":${MANPATH#"${MANPATH%%[!:]*}"}"; }
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
}

# pipx
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

# OrbStack command-line tools
[ -f "$HOME/.orbstack/shell/init.zsh" ] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

# Hyprland on tty1, as a uwsm-managed systemd session (the NixOS laptop; uwsm
# exists nowhere else). $TTY first: zsh sets it for free, while uwsm is python
# and every tmux pane is a login shell too. may-start also refuses when a
# graphical session is already running.
if [[ $TTY == /dev/tty1 ]] && command -v uwsm >/dev/null && uwsm check may-start -q; then
  exec uwsm start hyprland-uwsm.desktop
fi
