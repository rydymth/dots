#!/usr/bin/env bash
# Installs everything these dotfiles depend on. No Homebrew needed.
#
#   ./deps.sh                 install what is missing
#   ./deps.sh --check         only report, change nothing
#   ./deps.sh --force         reinstall tools into ~/.local even if the system has them
#   ./deps.sh --only fzf,node
#   ./deps.sh --skip tmux
#   ./deps.sh --list          show tool names
#
# Supports macOS (Intel + Apple Silicon), Fedora, and Debian/Ubuntu.
# Everything except the base system packages goes into ~/.local (no sudo, no
# package manager), so every colleague ends up with the same versions of the same
# tools. Safe to re-run. Written for bash 3.2 (the one macOS ships).

set -eo pipefail

# Neovim is pinned: lazy-lock.json and the roslyn.nvim pin were made against 0.11.x.
# Override with NVIM_VERSION=v0.12.x ./deps.sh when the config is moved forward.
NVIM_VERSION="${NVIM_VERSION:-v0.11.6}"

TOOLS="system zsh_plugins starship fzf zoxide direnv ripgrep fd neovim tmux node sqlcmd leaf"

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="$HOME/.local/bin"
OPT="$HOME/.local/opt"
PLUGINS="$XDG_DATA_HOME/zsh/plugins"
export PATH="$BIN:$PATH"

CHECK=0; FORCE=0; ONLY=""; SKIP=""
FAILED=""

# ── output ──────────────────────────────────────────────────────────────────
c()    { printf '\033[%sm' "$1"; }
say()  { printf '%s==>%s %s\n' "$(c '1;34')" "$(c 0)" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$(c 32)" "$(c 0)" "$*"; }
note() { printf '  %s·%s %s\n' "$(c 90)" "$(c 0)" "$*"; }
warn() { printf '  %s!%s %s\n' "$(c 33)" "$(c 0)" "$*" >&2; }
die()  { printf '%s✗%s %s\n' "$(c 31)" "$(c 0)" "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# ── platform ────────────────────────────────────────────────────────────────
OS=""; PM=""; ARCH=""
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) die "unsupported OS: $(uname -s)" ;;
esac
case "$(uname -m)" in
  x86_64|amd64)  ARCH=x64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) die "unsupported CPU: $(uname -m)" ;;
esac
if [[ $OS == linux && -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case " ${ID:-} ${ID_LIKE:-} " in
    *" fedora "*|*" rhel "*) PM=dnf ;;
    *" debian "*|*" ubuntu "*) PM=apt ;;
  esac
fi

# Release-asset names differ per project, so map our (OS, ARCH) once per naming style.
pick() {  # pick <macos-x64> <macos-arm64> <linux-x64> <linux-arm64>
  case "$OS-$ARCH" in
    macos-x64) echo "$1" ;; macos-arm64) echo "$2" ;;
    linux-x64) echo "$3" ;; linux-arm64) echo "$4" ;;
  esac
}
TRIPLE_MUSL="$(pick x86_64-apple-darwin aarch64-apple-darwin x86_64-unknown-linux-musl aarch64-unknown-linux-musl)"
TRIPLE_RG="$(pick x86_64-apple-darwin aarch64-apple-darwin x86_64-unknown-linux-musl aarch64-unknown-linux-gnu)"
FZF_PLAT="$(pick darwin_amd64 darwin_arm64 linux_amd64 linux_arm64)"
GO_PLAT="$(pick darwin-amd64 darwin-arm64 linux-amd64 linux-arm64)"
NVIM_PLAT="$(pick macos-x86_64 macos-arm64 linux-x86_64 linux-arm64)"
NODE_PLAT="$(pick darwin-x64 darwin-arm64 linux-x64 linux-arm64)"

# ── helpers ─────────────────────────────────────────────────────────────────
version_of() {  # first x.y.z found in a command's --version output
  "$@" 2>&1 | head -1 | sed -E 's/^[^0-9]*([0-9]+(\.[0-9]+)*).*/\1/'
}

# numeric compare on major.minor, which is all we ever need
at_least() {  # at_least <have> <major> <minor>
  local have="$1" want_major="$2" want_minor="$3" maj min
  maj="${have%%.*}"; min="${have#*.}"; [[ $min == "$have" ]] && min=0; min="${min%%.*}"
  [[ -n $maj ]] || return 1
  (( maj > want_major || (maj == want_major && ${min:-0} >= want_minor) ))
}

latest_tag() {  # latest_tag owner/repo -> tag name, via the redirect (no API rate limit)
  local u
  u="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest")"
  echo "${u##*/}"
}

fetch() { curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1"; }

sha256() { if has sha256sum; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }

cpus() { getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2; }

# Install one binary out of a release archive: bin_from_archive <name> <url>
bin_from_archive() {
  local name="$1" url="$2" tmp f
  tmp="$(mktemp -d)"
  mkdir -p "$BIN"
  note "downloading $url"
  if fetch "$url" "$tmp/archive" && tar -xf "$tmp/archive" -C "$tmp"; then
    f="$(find "$tmp" -type f -name "$name" | head -1)"
    if [[ -n $f ]]; then
      install -m 755 "$f" "$BIN/$name"
      ok "$name $(version_of "$BIN/$name" --version) -> $BIN/$name"
      rm -rf "$tmp"; return 0
    fi
  fi
  rm -rf "$tmp"
  warn "could not install $name"; FAILED="$FAILED $name"
}

# Skip a tool when it is already good. In --check mode, report and never install.
# usage: should_install <tool> <ok-command...>
should_install() {
  local tool="$1"; shift
  if (( ! FORCE )) && "$@"; then ok "$tool already installed"; return 1; fi
  if (( CHECK )); then warn "$tool is missing or too old"; FAILED="$FAILED $tool"; return 1; fi
  return 0
}

# ── checks ──────────────────────────────────────────────────────────────────
ok_fzf()  { has fzf && fzf --zsh >/dev/null 2>&1; }          # --zsh needs fzf >= 0.48
ok_nvim() { has nvim && [[ "$(version_of nvim --version)" == "${NVIM_VERSION#v}" ]]; }
ok_tmux() { has tmux && at_least "$(version_of tmux -V)" 3 2; }   # config uses popups and { } blocks
ok_node() { has node && at_least "$(version_of node -v)" 24 0; }

# ── stages ──────────────────────────────────────────────────────────────────
stage_system() {
  if [[ $OS == macos ]]; then
    if xcode-select -p >/dev/null 2>&1; then ok "Xcode command line tools present (git, clang, make)"; return; fi
    (( CHECK )) && { warn "Xcode command line tools missing"; FAILED="$FAILED xcode-clt"; return; }
    warn "installing Xcode command line tools: accept the dialog that opens"
    xcode-select --install || true
    die "re-run ./deps.sh once the Xcode tools finish installing"
  fi

  local pkgs missing="" p
  case "$PM" in
    dnf) pkgs="zsh tmux git curl unzip tar bzip2 gcc make ncurses-devel" ;;
    apt) pkgs="zsh tmux git curl unzip tar bzip2 xz-utils ca-certificates build-essential libncurses-dev" ;;
    *)   warn "unknown Linux distro: install zsh, tmux, git, curl, unzip, a C compiler and make yourself"; return ;;
  esac
  for p in $pkgs; do
    if [[ $PM == dnf ]]; then rpm -q "$p" >/dev/null 2>&1 || missing="$missing $p"
    else dpkg -s "$p" >/dev/null 2>&1 || missing="$missing $p"; fi
  done
  if [[ -z $missing ]]; then ok "base packages installed"; return; fi
  if (( CHECK )); then warn "missing packages:$missing"; FAILED="$FAILED system"; return; fi
  has sudo || die "sudo is required to install:$missing"
  note "installing:$missing"
  if [[ $PM == dnf ]]; then sudo dnf install -y $missing
  else sudo apt-get update -qq && sudo apt-get install -y $missing; fi
}

stage_zsh_plugins() {
  local name
  for name in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ -d $PLUGINS/$name/.git ]]; then
      (( CHECK )) || git -C "$PLUGINS/$name" pull -q --ff-only 2>/dev/null || true
      ok "$name present"
    elif (( CHECK )); then warn "$name missing"; FAILED="$FAILED $name"
    else
      mkdir -p "$PLUGINS"
      git clone -q --depth 1 "https://github.com/zsh-users/$name" "$PLUGINS/$name" \
        && ok "$name -> $PLUGINS/$name" || { warn "could not clone $name"; FAILED="$FAILED $name"; }
    fi
  done
}

stage_starship() {
  should_install starship has starship || return 0
  bin_from_archive starship \
    "https://github.com/starship/starship/releases/latest/download/starship-$TRIPLE_MUSL.tar.gz"
}

stage_fzf() {
  should_install fzf ok_fzf || return 0
  local tag; tag="$(latest_tag junegunn/fzf)"
  bin_from_archive fzf "https://github.com/junegunn/fzf/releases/download/$tag/fzf-${tag#v}-$FZF_PLAT.tar.gz"
}

stage_zoxide() {
  should_install zoxide has zoxide || return 0
  local tag; tag="$(latest_tag ajeetdsouza/zoxide)"
  bin_from_archive zoxide \
    "https://github.com/ajeetdsouza/zoxide/releases/download/$tag/zoxide-${tag#v}-$TRIPLE_MUSL.tar.gz"
}

stage_direnv() {
  should_install direnv has direnv || return 0
  local plat="${GO_PLAT}"
  mkdir -p "$BIN"
  if fetch "https://github.com/direnv/direnv/releases/latest/download/direnv.$plat" "$BIN/direnv"; then
    chmod 755 "$BIN/direnv"; ok "direnv $(version_of "$BIN/direnv" version) -> $BIN/direnv"
  else warn "could not install direnv"; FAILED="$FAILED direnv"; fi
}

stage_ripgrep() {
  should_install ripgrep has rg || return 0
  local tag; tag="$(latest_tag BurntSushi/ripgrep)"
  bin_from_archive rg "https://github.com/BurntSushi/ripgrep/releases/download/$tag/ripgrep-${tag#v}-$TRIPLE_RG.tar.gz"
}

stage_fd() {
  should_install fd has fd || return 0
  local tag; tag="$(latest_tag sharkdp/fd)"
  bin_from_archive fd "https://github.com/sharkdp/fd/releases/download/$tag/fd-$tag-$TRIPLE_MUSL.tar.gz"
}

stage_neovim() {
  should_install neovim ok_nvim || return 0
  local tmp d; tmp="$(mktemp -d)"
  mkdir -p "$OPT" "$BIN"
  note "downloading neovim ($NVIM_PLAT)"
  if fetch "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-$NVIM_PLAT.tar.gz" "$tmp/nvim.tgz" \
     && tar -xf "$tmp/nvim.tgz" -C "$tmp"; then
    d="$(find "$tmp" -maxdepth 1 -type d -name 'nvim-*' | head -1)"
    rm -rf "$OPT/nvim"; mv "$d" "$OPT/nvim"
    ln -sf "$OPT/nvim/bin/nvim" "$BIN/nvim"
    ok "neovim $(version_of "$BIN/nvim" --version) -> $BIN/nvim"
  else warn "could not install neovim"; FAILED="$FAILED neovim"; fi
  rm -rf "$tmp"
}

# No upstream tmux binaries exist, so build it (plus a static libevent) into ~/.local/opt.
stage_tmux() {
  should_install tmux ok_tmux || return 0
  has cc || has gcc || has clang || { warn "no C compiler: install Xcode tools / build-essential first"; FAILED="$FAILED tmux"; return 0; }
  local tag tmp deps="$OPT/tmux-deps" prefix="$OPT/tmux" log jobs
  tag="$(latest_tag tmux/tmux)"; jobs="$(cpus)"
  tmp="$(mktemp -d)"; log="$tmp/build.log"
  mkdir -p "$OPT" "$BIN"
  note "building tmux $tag (a minute or two)"
  if (
    set -e
    cd "$tmp"
    fetch "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz" le.tgz
    tar -xf le.tgz && cd libevent-2.1.12-stable
    ./configure --prefix="$deps" --disable-shared --disable-openssl --disable-samples --disable-libevent-regress
    make -j"$jobs" && make install
    cd "$tmp"
    fetch "https://github.com/tmux/tmux/releases/download/$tag/tmux-$tag.tar.gz" tmux.tgz
    tar -xf tmux.tgz && cd "tmux-$tag"
    ./configure --prefix="$prefix" \
      LIBEVENT_CFLAGS="-I$deps/include" LIBEVENT_LIBS="-L$deps/lib -levent_core"
    make -j"$jobs" && make install
  ) >"$log" 2>&1; then
    ln -sf "$prefix/bin/tmux" "$BIN/tmux"
    ok "tmux $(version_of "$BIN/tmux" -V) -> $BIN/tmux"
  else
    warn "tmux build failed; last lines of the log:"; tail -15 "$log" >&2
    FAILED="$FAILED tmux"
  fi
  rm -rf "$tmp"
}

stage_node() {
  should_install node ok_node || return 0
  local tmp sums line file hash d; tmp="$(mktemp -d)"
  mkdir -p "$OPT" "$BIN"
  fetch "https://nodejs.org/dist/latest-v24.x/SHASUMS256.txt" "$tmp/sums"
  line="$(grep -E "node-v[0-9.]+-$NODE_PLAT\.tar\.gz\$" "$tmp/sums" | head -1)"
  hash="${line%% *}"; file="${line##* }"
  [[ -n $file ]] || { warn "no Node 24 build for $NODE_PLAT"; FAILED="$FAILED node"; rm -rf "$tmp"; return 0; }
  note "downloading $file"
  fetch "https://nodejs.org/dist/latest-v24.x/$file" "$tmp/node.tgz"
  [[ "$(sha256 "$tmp/node.tgz")" == "$hash" ]] || { warn "checksum mismatch for $file"; FAILED="$FAILED node"; rm -rf "$tmp"; return 0; }
  tar -xf "$tmp/node.tgz" -C "$tmp"
  d="$(find "$tmp" -maxdepth 1 -type d -name 'node-v*' | head -1)"
  rm -rf "$OPT/node-24"; mv "$d" "$OPT/node-24"
  for t in node npm npx; do ln -sf "$OPT/node-24/bin/$t" "$BIN/$t"; done
  ok "node $(node -v), npm $(npm -v) (checksum verified)"
  rm -rf "$tmp"
}

stage_leaf() {   # terminal markdown viewer; release asset is a bare binary
  should_install leaf has leaf || return 0
  mkdir -p "$BIN"
  if fetch "https://github.com/RivoLink/leaf/releases/latest/download/leaf-$NVIM_PLAT" "$BIN/leaf"; then
    chmod 755 "$BIN/leaf"; ok "leaf $(version_of "$BIN/leaf" --version) -> $BIN/leaf"
  else rm -f "$BIN/leaf"; warn "could not install leaf"; FAILED="$FAILED leaf"; fi
}

stage_sqlcmd() {
  should_install sqlcmd has sqlcmd || return 0
  bin_from_archive sqlcmd "https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-$GO_PLAT.tar.bz2"
}

# ── arguments ───────────────────────────────────────────────────────────────
usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while (( $# )); do
  case "$1" in
    --check|--dry-run|-n) CHECK=1 ;;
    --force) FORCE=1 ;;
    --only)  ONLY="${2:?--only needs a comma list}"; shift ;;
    --skip)  SKIP="${2:?--skip needs a comma list}"; shift ;;
    --list)  for t in $TOOLS; do echo "$t"; done; exit 0 ;;
    -h|--help) usage 0 ;;
    *) echo "unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

selected() {
  [[ -n $ONLY && ",$ONLY," != *",$1,"* ]] && return 1
  [[ -n $SKIP && ",$SKIP," == *",$1,"* ]] && return 1
  return 0
}

say "platform: $OS/$ARCH${PM:+ ($PM)}"
for t in $TOOLS; do
  selected "$t" || continue
  say "$t"
  "stage_$t"
done

echo
if [[ -n $FAILED ]]; then
  warn "needs attention:$FAILED"
  exit 1
fi
say "all dependencies in place"
