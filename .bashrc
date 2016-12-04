source ~/.qcshext/qcrc
#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# source git prompt and git completion
source ~/.config/git-prompt.sh
source ~/.config/git-completion.bash

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=8192
export HISTFILESIZE=500000000
shopt -s histappend                      # append to history, don't overwrite it


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes


PS1='\[\e[32m\]\u@\h\[\e[m\]:\w$(__git_ps1)\n\$ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CFh'
alias mc='mc -S $HOME/.config/mc/solarized.ini'


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# disable annoying crtl+s and crtl+q
stty stop undef
stty start undef

# vim like mode
set -o vi
export EDITOR=`which vim`


if [ -f ~/.dynamic-colors  ]; then
    export PATH="$HOME/.dynamic-colors/bin:$PATH"
    source $HOME/.dynamic-colors/completions/dynamic-colors.bash
fi


# platform specific stuff
if [ "$HOSTNAME" = piecyk ]; then
    if [ -f /usr/bin/virtualenvwrapper.sh ]; then
        export WORKON_HOME=/home/lukhar/workspace/.environments
        source /usr/bin/virtualenvwrapper.sh
        export NOTES=$HOME/documents/shared/notes
    fi
    export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

    # ugly fix for bold fonts in tmux
    alias tmux='TERM=xterm-256color /usr/bin/tmux'
fi

if [ "$HOSTNAME" = jabcok ]; then
    if [ -f /usr/local/bin/virtualenvwrapper.sh  ]; then
        export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
        export WORKON_HOME=$HOME/workspace/.environments
        export PATH="/usr/local/sbin:$PATH"
        export NOTES=$HOME/Documents/shared/notes
        source /usr/local/bin/virtualenvwrapper_lazy.sh
    fi

    if [ -f /usr/local/etc/profile.d/bash_completion.sh ]; then
        . /usr/local/etc/profile.d/bash_completion.sh
    fi

    alias ls='ls -G'
    alias vim='/usr/local/bin/vim'
    alias nvim='DYLD_FORCE_FLAT_NAMESPACE=1 nvim'
fi

if [ "$HOSTNAME" = fruitbox ]; then
    export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
    export WORKON_HOME=$HOME/workspace/.environments
    export PATH="/usr/local/sbin:$PATH"
    export NOTES=$HOME/Documents/shared/notes
    export EDITOR='/usr/local/bin/vim'
    export GITHUB_HOST=github.corp.qc
    source /usr/local/bin/virtualenvwrapper_lazy.sh

    alias ls='ls -G'
    alias vim='/usr/local/bin/vim'
    alias nvim='DYLD_FORCE_FLAT_NAMESPACE=1 nvim'
    alias git=hub
    source /usr/local/etc/bash_completion.d/hub.bash_completion.sh
fi

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;016m\E[48;5;220m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

if [ -d $HOME/.sdkman ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

if [ -d /opt/torch ]; then
    . /opt/torch/install/bin/torch-activate
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
