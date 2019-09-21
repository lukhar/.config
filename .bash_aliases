if [ $HOSTNAME = piecyk ]; then
  alias ls='ls --color=auto'
fi
if [ $HOSTNAME = fruitbox ]; then
  alias ls='ls -G'
fi

alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CFh'
alias mc='mc -S $HOME/.config/mc/solarized.ini'

alias lsoftcp='lsof -iTCP -sTCP:LISTEN -n -P'

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

alias snvim='nvim -c "colorscheme jellybeans"'
alias tailf='tail -f'


function hfsplus_mount() {
    sudo mount -t hfsplus $1 $2
}

alias hmount=hfsplus_mount


vf() {
  nvim ${@:2} $(fd -i -t f | fzf --multi -q "$1" --preview='bat --color "always" {}' )
}

fkill() {
  pid=$(ps aux | fzf -q "$1" --multi --header-lines=1 | awk '{print $2}')  && kill $pid
}

if [ -x "$(command -v bat)"  ]; then
  alias catp='bat -p'
  alias cat='bat --theme=solarized_dark'
fi

if [ -x "$(command -v kubectl)" ]; then
  alias k=kubectl
  complete -F __start_kubectl k
fi
