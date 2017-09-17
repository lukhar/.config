echo "hello from profile"

if hash setxkbmap 2>/dev/null; then
    setxkbmap pl -option caps:escape
fi
