if hash setxkbmap 2>/dev/null; then
    setxkbmap pl -option caps:escape
fi

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/bin:$PATH"
