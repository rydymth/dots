# navigation
alias ..='cd ..'
alias ...='cd ../..'
if ls --color=auto >/dev/null 2>&1; then alias ll='ls -lah --color=auto'; else alias ll='ls -lahG'; fi  # GNU vs BSD ls

# git
alias g='git'
alias gs='git status -sb'

# tmux
alias t='tmux'
alias ta='tmux attach -t'
alias tl='tmux ls'

# dotnet
alias dn='dotnet'
alias dnr='dotnet run'
alias dnb='dotnet build'
alias dnt='dotnet test'

# git history
alias gl='git log --graph --abbrev-commit --decorate --date=relative --format=format:"%C(bold blue)%h%C(reset) %C(green)(%ar)%C(reset) %s %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)" -20'
alias gla='gl --all'                 # all branches
alias glf='git log --stat -10'       # which files changed
alias glp='git log -p -5'            # with the actual diffs
alias gls='git shortlog -sn'         # who committed how much
alias gd='git diff'
alias gds='git diff --staged'
