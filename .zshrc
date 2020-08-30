source ~/.zplug/init.zsh
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions",  defer:2, on:"zsh-users/zsh-completions"
export NVM_LAZY_LOAD=true
zplug "lukechilds/zsh-nvm"
zplug load

[ "$HOST" = 'piecyk' ] && SPACESHIP_CHAR_SUFFIX="  "

[ "$HOST" = 'piecyk' ] && eval `dircolors ~/.config/.dircolors`
## Options section
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
HISTFILE=~/.zhistory
HISTSIZE=500000000
SAVEHIST=5000
export EDITOR=`which nvim`
WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word


bindkey '^ ' autosuggest-accept                                 # use ctrl + space to accept current suggestion

## vi mode adjustments
bindkey -v

autoload -z edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/[% NORMAL]%}/(main|viins)/[% INSERT]%}"
}

## Alias section 
[ "$HOST" = 'piecyk' ] && alias ls='ls --color=auto'
[ "$HOST" = 'fruitbox' ] && alias ls='ls -G'

# ugly fix for bold fonts in tmux
[ "$HOST" = 'piecyk' ] && alias tmux='TERM=xterm-256color /usr/bin/tmux'
[ -x "$(command -v bat)" ] && alias cat=bat

alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CFh'
alias mc='mc -S $HOME/.config/mc/solarized.ini'

alias cp="cp -i"                                                # Confirm before overwriting something
alias df='df -h'                                                # Human-readable sizes
alias free='free -m'                                            # Show sizes in MB
alias gitu='git add . && git commit && git push'

[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases


if [[ "$HOST" = 'piecyk' ]]; then
  case $(basename "$(cat "/proc/$PPID/comm")") in
    login)
        alias x='startx ~/.xinitrc'      # Type name of desired desktop after x, xinitrc is configured for it
      ;;
    'tmux: server')
      theme="solarized"
      shade="dark"
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
        ZSH_AUTOSUGGEST_USE_ASYNC=true
       ;;
    *)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
        ZSH_AUTOSUGGEST_USE_ASYNC=true
      ;;
  esac
fi

[ -d $HOME/.fzf ] && source ~/.fzf.zsh

export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:$PATH
export PATH=$HOME/bin:$PATH
export NOTES=$HOME/documents/shared/notes

export PATH="$HOME/.rbenv/bin:$PATH"
[ -x "$(command -v rbenv)" ] && eval "$(rbenv init -)"

[ -x "$(command -v pipx)" ] && export PATH=$HOME/.local/bin:$PATH

[ -x "$(command -v pyenv)" ] && eval "$(pyenv init -)"
[ -x "$(command -v pyenv)" ] && eval "$(pyenv virtualenv-init -)"

[ -x "$(command -v hub)" ] && eval "$(hub alias -s)"

[ -d $HOME/.sdkman ] && source $HOME/.sdkman/bin/sdkman-init.sh

# vim: tabstop=2 shiftwidth=2 expandtab
