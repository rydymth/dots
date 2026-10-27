for f in "$ZDOTDIR"/env/*.zsh(N); do
    source "$f"
done
unset f
