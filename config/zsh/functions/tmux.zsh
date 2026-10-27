# attach to a session, or create it if it doesn't exist
tn() { tmux new-session -A -s "${1:-dev}"; }

# fuzzy-pick a session: switches inside tmux, attaches outside it
ts() {
  local s
  s=$(tmux list-sessions -F '#S' 2>/dev/null | grep -vx scratch | fzf --reverse --prompt='session> ') || return
  if [[ -n $TMUX ]]; then tmux switch-client -t "$s"; else tmux attach -t "$s"; fi
}

# kill a session by name (default: the current one)
tk() { tmux kill-session -t "${1:-$(tmux display-message -p '#S')}"; }
