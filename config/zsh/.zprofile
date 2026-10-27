# macOS runs /etc/zprofile (path_helper) AFTER .zshenv, which pushes ~/.local/bin behind
# the system paths. Re-read the env files so our PATH entries win again.
if [[ $OSTYPE == darwin* ]]; then
    for f in "$ZDOTDIR"/env/*.zsh(N); do source "$f"; done
    unset f
fi
