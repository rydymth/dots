# Colour theme chosen with the `theme` command. Falls back to the defaults if it was never run.
_theme_state="$XDG_STATE_HOME/theme"
[[ -r $_theme_state/starship.toml ]] && export STARSHIP_CONFIG="$_theme_state/starship.toml"
[[ -r $_theme_state/fzf.zsh ]] && source "$_theme_state/fzf.zsh"
unset _theme_state
