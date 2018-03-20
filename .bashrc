#!/bin/bash

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

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

PS1='${TERRAFORM_WORKSPACE}${PYTHON_VIRTUALENV}\[\e[32m\]\u@\h\[\e[m\]:\w$(__git_ps1)\n\$ '

source $HOME/.config/.bash_aliases

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

# vim like mode
set -o vi
export EDITOR=`which vim`

# command line copy paste for tmux
if [ ! $(uname -s) = "Darwin"  ]; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# platform specific stuff
if [ "$HOSTNAME" = piecyk ]; then
  export NOTES=$HOME/documents/shared/notes

  # ugly fix for bold fonts in tmux
  alias tmux='TERM=xterm-256color /usr/bin/tmux'
fi

if [ "$HOSTNAME" = fruitbox ]; then
  source $HOME/.config/.fruitbox_aliases
fi

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;016m\E[48;5;220m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# vim: tabstop=2 shiftwidth=2 expandtab
