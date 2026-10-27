# --- vi mode ---
bindkey -v
export KEYTIMEOUT=1                      # Esc responds in 10 ms (default is 400)

# --- edit the current command line in $EDITOR (nvim) ---
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^e' edit-command-line   # Esc, then Ctrl-e (v stays visual mode)
bindkey '^x^e' edit-command-line         # works from insert mode too

# --- line start / end / history in insert mode (normal mode already has 0, ^, $) ---
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
bindkey -M viins '^k' kill-line
bindkey -M viins '^w' backward-kill-word
bindkey -M viins '^?' backward-delete-char   # Backspace keeps working after leaving normal mode
bindkey -M viins '^p' up-line-or-history
bindkey -M viins '^n' down-line-or-history

# --- cursor shape: beam while typing, block in normal mode ---
autoload -Uz add-zle-hook-widget
_cursor_shape() {
  case $KEYMAP in
    vicmd) print -n '\e[2 q' ;;          # block
    *)     print -n '\e[6 q' ;;          # beam
  esac
}
add-zle-hook-widget keymap-select _cursor_shape
add-zle-hook-widget line-init _cursor_shape
