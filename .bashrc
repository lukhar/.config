# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# source git prompt and git completion
source ~/.config/git-prompt.sh
source ~/.config/git-completion.bash

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth
HISTFILESIZE=25000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
    screen-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1)\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

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
export EDITOR="/usr/local/bin/vim"

export GRADLE_HOME="/opt/gradle"
export GRADLE_OPTS="-Dorg.gradle.daemon=true"

PATH="$GRADLE_HOME/bin:$PATH"
PATH="$MVN_HOME/bin:$PATH"
PATH="$SCALA_HOME/bin:$PATH"

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

    # ugly hack to have servermode in vim (GVIM is server name by default)
    alias gvim='DYLD_FORCE_FLAT_NAMESPACE=1 vim'
    alias vim='DYLD_FORCE_FLAT_NAMESPACE=1 vim --servername GVIM'

    alias ls='ls -G'
fi

if [ "$HOSTNAME" = fruitbox ]; then
    export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
    export WORKON_HOME=$HOME/workspace/.environments
    export PATH="/usr/local/sbin:$PATH"
    export NOTES=$HOME/Documents/shared/notes
    source /usr/local/bin/virtualenvwrapper_lazy.sh

    alias ls='ls -G'
    alias nvim='DYLD_FORCE_FLAT_NAMESPACE=1 nvim'
fi

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;016m\E[48;5;220m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

if [ -d /opt/torch ]; then
    . /opt/torch/install/bin/torch-activate
fi
