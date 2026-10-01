#!/bin/bash

mkdir -p ~/bin
mkdir -p ~/.cache/vim/swp
mkdir -p ~/.cache/vim/undo
mkdir -p ~/sdk
mkdir -p ~/.claude          # the aiassist links below land inside it

ln -sf ~/.config/.bashrc ~/.bashrc
# The only zsh file $HOME needs: it sets ZDOTDIR, and zsh finds .zshrc,
# .zprofile and the aliases under $XDG_CONFIG_HOME/zsh from there.
ln -sf ~/.config/zsh/.zshenv ~/.zshenv
ln -sf ~/.config/.bash_profile ~/.bash_profile
ln -sf ~/.config/.inputrc ~/.inputrc
ln -sf ~/.config/.Xresources ~/.Xresources   # merged by the display manager
ln -sf ~/.config/.profile ~/.profile
ln -sf ~/.config/.xinitrc ~/.xinitrc
ln -sf ~/.config/aiassist/claude/rules ~/.claude/rules
ln -sf ~/.config/aiassist/claude/skills ~/.claude/skills
ln -sf ~/.config/aiassist/claude/agents ~/.claude/agents

if [ "$(uname -s)" = Darwin ] && [ -d ~/Dropbox/Shared ]; then
  ln -sf ~/Dropbox/Shared ~/Documents/shared
fi
