#!/bin/bash

mkdir -p ~/bin
mkdir -p ~/.cache/vim/swp
mkdir -p ~/.cache/vim/undo
mkdir -p ~/sdk

ln -sf ~/.config/.agignore ~/.agignore
ln -sf ~/.config/.bashrc ~/.bashrc
ln -sf ~/.config/.dmrc ~/.dmrc
ln -sf ~/.config/zsh/zshrc ~/.zshrc
ln -sf ~/.config/zsh/zshenv ~/.zshenv
ln -sf ~/.config/zsh/zsh_aliases ~/.zsh_aliases
ln -sf ~/.config/.bash_profile ~/.bash_profile
ln -sf ~/.config/.bash_aliases ~/.bash_aliases
ln -sf ~/.config/confupdate.sh ~/bin/confupdate
ln -sf ~/.config/.dircolors ~/.dircolors
ln -sf ~/.config/.gitignore ~/.gitignore
ln -sf ~/.config/.inputrc ~/.inputrc
ln -sf ~/.config/.profile ~/.profile
ln -sf ~/.config/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.config/tmux/tools/safe-reattach-to-user-namespace ~/bin/safe-reattach-to-user-namespace
ln -sf ~/.config/.Xresources ~/.Xresources
ln -sf ~/.config/.Xclients ~/.Xclients
ln -sf ~/.config/.xinitrc ~/.xinitrc
ln -sf ~/.vim/gvimrc ~/.gvimrc
ln -sf ~/.vim/vimrc ~/.vimrc
ln -sf ~/.config/ctags ~/.ctags.d 
ln -sf ~/.config/.gtkrc-2.0 ~/.gtkrc-2.0

if [ "$HOSTNAME" = fruitbox ]; then
  ln -sf ~/Dropbox/Shared ~/Documents/shared
fi

if [ "$HOSTNAME" = piecyk ]; then
  rm ~/.config/ctags/ctags
fi
