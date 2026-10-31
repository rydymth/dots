#!/usr/bin/env bash
# Reproducible bash -> zsh dev environment (Fedora on WSL, Debian/Ubuntu, macOS).
#
#   ./install.sh                 run every stage
#   ./install.sh --dry-run       print what would happen, change nothing
#   ./install.sh --only link,nvim
#   ./install.sh --skip deps,shell
#   ./install.sh --list          show stage names
#
# Safe to re-run: every stage checks state first and does nothing if it is
# already correct. Anything it replaces is moved to a timestamped backup folder.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGES=(preflight deps link theme secrets bash_cleanup shell wsl nvim verify)

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BIN="$HOME/.local/bin"
BACKUP="$XDG_STATE_HOME/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# repo path (relative to config/)   ->   target under $XDG_CONFIG_HOME
CONFIG_LINKS=(zsh tmux nvim leaf theme)

# ── helpers ─────────────────────────────────────────────────────────────────
DRY=0; ONLY=""; SKIP=""
c() { printf '\033[%sm' "$1"; }
say()  { printf '%s==>%s %s\n' "$(c 1\;34)" "$(c 0)" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$(c 32)" "$(c 0)" "$*"; }
note() { printf '  %s·%s %s\n' "$(c 90)" "$(c 0)" "$*"; }
warn() { printf '  %s!%s %s\n' "$(c 33)" "$(c 0)" "$*" >&2; }
die()  { printf '%s✗%s %s\n' "$(c 31)" "$(c 0)" "$*" >&2; exit 1; }

# run a command, or just print it in --dry-run
run() {
  if (( DRY )); then printf '  %s$%s %s\n' "$(c 90)" "$(c 0)" "$*"; else "$@"; fi
}

has() { command -v "$1" >/dev/null 2>&1; }

backup() {          # move a path into the backup folder, keeping its relative name
  local p="$1"
  run mkdir -p "$BACKUP"
  run mv "$p" "$BACKUP/$(basename "$p")"
  note "backed up $p -> $BACKUP/"
}

link() {            # link <source-in-repo> <target>
  local src="$1" dst="$2"
  if [[ -L $dst && "$(readlink "$dst")" == "$src" ]]; then
    ok "$dst (already linked)"; return
  fi
  run mkdir -p "$(dirname "$dst")"
  if [[ -e $dst || -L $dst ]]; then backup "$dst"; fi
  run ln -s "$src" "$dst"
  ok "$dst -> $src"
}

# ── stages ──────────────────────────────────────────────────────────────────
stage_preflight() {
  [[ $EUID -ne 0 ]] || die "run as your normal user, not root (sudo is used when needed)"
  if [[ "$(uname -s)" == Darwin ]]; then ok "macOS $(sw_vers -productVersion) ($(uname -m))"
  else
    [[ -r /etc/os-release ]] && . /etc/os-release
    ok "${PRETTY_NAME:-Linux}"
  fi
  grep -qi microsoft /proc/version 2>/dev/null && ok "running inside WSL" || note "not WSL: the 'wsl' stage will be skipped"
  has sudo || die "sudo is required"
  has curl || has dnf || die "need dnf or curl to bootstrap"
  ok "repo: $REPO"
}

# Everything that needs downloading lives in deps.sh (macOS, Fedora, Debian/Ubuntu).
stage_deps() {
  if (( DRY )); then "$REPO/deps.sh" --check || true; else "$REPO/deps.sh"; fi
}

stage_link() {
  local item live_secrets="$XDG_CONFIG_HOME/zsh/env/99-secrets.zsh"
  # First run on an existing machine: ~/.config/zsh is a real dir about to be replaced
  # by a symlink. Carry the secrets file into the repo copy so it keeps working.
  if [[ -f $live_secrets && ! -L $XDG_CONFIG_HOME/zsh && ! -e $REPO/config/zsh/env/99-secrets.zsh ]]; then
    run install -m 600 "$live_secrets" "$REPO/config/zsh/env/99-secrets.zsh"
    ok "carried existing 99-secrets.zsh into the repo copy (git-ignored)"
  fi
  for item in "${CONFIG_LINKS[@]}"; do
    link "$REPO/config/$item" "$XDG_CONFIG_HOME/$item"
  done
  # the `theme` switcher on PATH
  link "$XDG_CONFIG_HOME/theme/theme" "$BIN/theme"
  # ~/.zshenv is the one file zsh reads from $HOME. It points zsh at ~/.config/zsh.
  link "$REPO/home/zshenv" "$HOME/.zshenv"

  # dirs that tools expect to exist
  run mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" \
               "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh" \
               "$XDG_CONFIG_HOME/npm" "$HOME/.local/langs/npm_global"
}

stage_theme() {
  local t="$XDG_CONFIG_HOME/theme/theme"
  [[ -x $t ]] || { warn "theme script not linked yet"; return; }
  # keep the theme you already chose; first run gets the default
  if [[ -r $XDG_STATE_HOME/theme/current ]]; then
    ok "theme: $("$t" --current) (unchanged; run 'theme' to list, 'theme <name>' to switch)"
  else
    run "$t" apple-classic-dark
  fi
}

stage_secrets() {
  local f="$XDG_CONFIG_HOME/zsh/env/99-secrets.zsh"
  if [[ -f $f ]]; then
    run chmod 600 "$f"; ok "$f exists (mode 600), not touched"; return
  fi
  run install -m 600 "$REPO/secrets.template.zsh" "$f"
  ok "created $f from template"
  warn "fill in the DB_*_URL values yourself; this file is git-ignored"
}

stage_bash_cleanup() {
  [[ "$(uname -s)" == Darwin ]] && { note "macOS: leaving bash files alone"; return; }
  local f found=0
  for f in .bashrc .bash_profile .bash_login .bash_logout .profile; do
    [[ -e $HOME/$f ]] || continue
    found=1; backup "$HOME/$f"
  done
  (( found )) || ok "no bash startup files left in \$HOME"
  # history is kept on purpose: it is yours, and zsh does not read it
  [[ -e $HOME/.bash_history ]] && note "kept ~/.bash_history (delete by hand if you want)"
  return 0
}

stage_shell() {
  [[ "$(uname -s)" == Darwin ]] && { ok "macOS already uses zsh"; return; }
  local zsh_path=/usr/bin/zsh
  [[ -x $zsh_path ]] || { warn "zsh not installed yet, run the deps stage"; return; }
  local cur; cur="$(getent passwd "$USER" | cut -d: -f7)"
  if [[ "$(readlink -f "$cur")" == "$(readlink -f "$zsh_path")" ]]; then
    ok "login shell is already zsh ($cur)"; return
  fi
  # plain `chsh` needs a password that WSL users often never set; sudo avoids that
  run sudo chsh -s "$zsh_path" "$USER"
  ok "login shell -> $zsh_path (takes effect on next login: run 'wsl --terminate' from Windows)"
}

stage_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null || { note "not WSL, skipping"; return; }

  # With .wslconfig networkingMode=mirrored, NetworkManager fights WSL for eth0 and
  # boot hangs in "starting". Tell it to leave the WSL interfaces alone.
  local nm=/etc/NetworkManager/conf.d/10-wsl-unmanaged.conf
  if [[ -f $nm ]] && cmp -s "$REPO/system/10-wsl-unmanaged.conf" "$nm"; then
    ok "$nm already in place"
  else
    run sudo install -D -m 644 "$REPO/system/10-wsl-unmanaged.conf" "$nm"
    ok "installed $nm"
  fi
  if [[ "$(systemctl is-enabled NetworkManager-wait-online 2>/dev/null || true)" != masked ]]; then
    run sudo systemctl mask NetworkManager-wait-online
    ok "masked NetworkManager-wait-online"
  else ok "NetworkManager-wait-online already masked"; fi

  # The Microsoft repo on Fedora points at fedora/40 and only spams GPG warnings.
  local ms=/etc/yum.repos.d/packages-microsoft-com-prod.repo
  if [[ -f $ms ]] && grep -q '^enabled=1' "$ms"; then
    run sudo dnf config-manager setopt packages-microsoft-com-prod.enabled=0
    ok "disabled packages-microsoft-com-prod"
  fi
}

stage_nvim() {
  has nvim || { warn "nvim missing, skipping plugin install"; return; }
  [[ -f $XDG_CONFIG_HOME/nvim/init.lua ]] || { warn "nvim config not linked yet"; return; }
  note "installing plugins from lazy-lock.json (first run takes a minute)"
  # restore = exact versions from lazy-lock.json, so roslyn.nvim stays pinned
  run nvim --headless "+Lazy! restore" +qa
  note "installing LSP/debug tools via mason (roslyn, netcoredbg, lua-language-server)"
  run nvim --headless "+Lazy! load mason-tool-installer.nvim" "+MasonToolsInstallSync" +qa
  ok "neovim ready"
}

stage_verify() {
  local zsh_bin; zsh_bin="$(command -v zsh || true)"
  [[ -n $zsh_bin ]] || { warn "zsh not found"; return; }
  (( DRY )) && { note "skipped in dry-run"; return; }
  local out
  out="$("$zsh_bin" -ic 'print -r -- "ZDOTDIR=$ZDOTDIR"
    print -r -- "node=$(command -v node) $(node -v 2>&1)"
    print -r -- "npm prefix=$(npm config get prefix 2>&1)"
    print -r -- "EDITOR=$EDITOR"
    print -r -- "DOTNET_CLI_HOME=$DOTNET_CLI_HOME"
    print -r -- "starship=$(command -v starship)"' 2>&1 | grep -v '^$' || true)"
  printf '%s\n' "$out" | sed 's/^/    /'
  echo
  say "stray dot-items in \$HOME (expected: .aspnet .dotnet .ssh .zshenv .cache .config .local)"
  ( cd "$HOME" && ls -A | grep '^\.' | tr '\n' ' ' ); echo
}

# ── argument parsing ────────────────────────────────────────────────────────
usage() { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while (( $# )); do
  case "$1" in
    --dry-run|-n) DRY=1 ;;
    --only)  ONLY="${2:?--only needs a comma list}"; shift ;;
    --skip)  SKIP="${2:?--skip needs a comma list}"; shift ;;
    --list)  printf '%s\n' "${STAGES[@]}"; exit 0 ;;
    -h|--help) usage 0 ;;
    *) echo "unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

selected() {
  local s="$1"
  [[ -n $ONLY && ",$ONLY," != *",$s,"* ]] && return 1
  [[ -n $SKIP && ",$SKIP," == *",$s,"* ]] && return 1
  return 0
}

(( DRY )) && warn "dry-run: nothing will be changed"
for s in "${STAGES[@]}"; do
  selected "$s" || continue
  say "$s"
  "stage_$s"
done

echo
say "done. Open a new terminal (or run: exec zsh)."
