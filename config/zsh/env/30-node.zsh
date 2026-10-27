export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"   # replaces ~/.npmrc
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"               # replaces ~/.npm
export NPM_CONFIG_PREFIX="$HOME/.local/langs/npm_global"    # global installs
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
path+=("$NPM_CONFIG_PREFIX/bin")
