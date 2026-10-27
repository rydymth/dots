# history
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# completion
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# aliases and functions
source "$ZDOTDIR/aliases.zsh"
for f in "$ZDOTDIR"/functions/*.zsh(N); do
    source "$f"
done
unset f

# vi mode and keybinds (before tools, so fzf and starship hook in afterwards)
source "$ZDOTDIR/keybinds.zsh"

# tools
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
source <(fzf --zsh)
eval "$(starship init zsh)"

# Angular CLI completion, loaded on first use (loading it eagerly costs ~0.4s per shell)
ng() { unfunction ng; source <(command ng completion script); ng "$@"; }

# plugins (keep syntax-highlighting last). deps.sh clones them into XDG_DATA_HOME;
# distro packages and Homebrew locations are fallbacks.
_plugin() {
    local name=$1 dir
    for dir in "$XDG_DATA_HOME/zsh/plugins/$name" "/usr/share/$name" \
               "/opt/homebrew/share/$name" "/usr/local/share/$name"; do
        [[ -r $dir/$name.zsh ]] && { source "$dir/$name.zsh"; return; }
    done
}
_plugin zsh-autosuggestions
bindkey '^f' autosuggest-accept          # Ctrl-f accepts the grey suggestion
_plugin zsh-syntax-highlighting
unfunction _plugin
