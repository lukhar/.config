alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CFh'
alias mc='mc -S $HOME/.config/mc/solarized.ini'
alias ls='ls -G'

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
