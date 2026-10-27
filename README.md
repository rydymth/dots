# dotfiles

Fedora on WSL, Debian/Ubuntu and macOS (Intel and Apple Silicon): zsh (vi mode, starship), tmux, Neovim. XDG layout, no dot-folders in `$HOME`
beyond the few tools that hard-code them (`.aspnet`, `.dotnet`, `.ssh`).

## Rebuild from scratch

```sh
git clone <your-gitea-url>/dotfiles.git ~/docs/dotfiles
cd ~/docs/dotfiles
./install.sh --dry-run     # read what it will do
./install.sh
```

Then, from Windows, restart WSL so the new login shell and network config apply:

```powershell
wsl --terminate FedoraLinux-43
```

## Layout

| Repo path | Linked to | Purpose |
|---|---|---|
| `home/zshenv` | `~/.zshenv` | sets `XDG_*` and `ZDOTDIR`, then loads `~/.config/zsh/.zshenv` |
| `config/zsh/` | `~/.config/zsh` | `.zshrc`, `keybinds.zsh`, `aliases.zsh`, `functions/`, `env/` |
| `config/tmux/` | `~/.config/tmux` | `tmux.conf` loads `conf.d/*.conf` in order |
| `config/nvim/` | `~/.config/nvim` | lazy.nvim config, one file per plugin group |
| `config/leaf/` | `~/.config/leaf` | leaf markdown viewer: `config.toml` + `themes/apple-classic-dark.toml` |
| `config/starship.toml` | `~/.config/starship.toml` | prompt |
| `system/` | `/etc/...` (copied, needs sudo) | WSL NetworkManager fix |
| `secrets.template.zsh` | `~/.config/zsh/env/99-secrets.zsh` | copied once, never overwritten |

Files are **symlinked**, so editing `~/.config/zsh/aliases.zsh` edits the repo. Commit from here.

## Stages

`./install.sh --list` prints them. Run any subset with `--only` / `--skip`.

| Stage | What it does |
|---|---|
| `preflight` | checks you are a normal user with sudo; prints the OS |
| `deps` | runs `deps.sh` (see below) |
| `link` | symlinks the config; existing files go to a backup folder |
| `secrets` | creates `99-secrets.zsh` (mode 600) from the template if absent |
| `bash_cleanup` | Linux only: moves `.bashrc`, `.bash_profile`, `.profile`... to the backup folder |
| `shell` | Linux only: `sudo chsh -s zsh` (macOS already uses zsh) |
| `wsl` | WSL only: NetworkManager unmanaged-devices + mask wait-online; disable the Fedora-40 Microsoft repo |
| `nvim` | `Lazy! restore` (exact versions from `lazy-lock.json`) + Mason tools |
| `verify` | opens an interactive zsh and prints the resolved env |

## Dependencies: `deps.sh`

Runs standalone too (`./deps.sh --check` reports without changing anything). No Homebrew.

- **System packages** (dnf / apt; Xcode command line tools on macOS): git, zsh, tmux, compiler, ncurses headers.
- **Into `~/.local`, same versions on every OS**: starship, fzf, zoxide, direnv, ripgrep, fd, leaf,
  Neovim (pinned to 0.11.6, override with `NVIM_VERSION=v0.12.x`), Node 24 (checksum-verified), sqlcmd.
- **zsh plugins**: cloned into `~/.local/share/zsh/plugins`.
- **tmux**: built from source (plus a static libevent) when the system one is missing or older than 3.2.
- Tools already on the system are left alone; `--force` installs the `~/.local` copy anyway.
- Flags: `--check`, `--force`, `--only a,b`, `--skip a,b`, `--list`.

On macOS the first run may pop up the Xcode tools installer. Accept it and run the script again.

Backups land in `~/.local/state/dotfiles-backup/<timestamp>/`. Nothing is deleted.

## Secrets

`config/zsh/env/99-secrets.zsh` is git-ignored. It holds `DB_PODMAN_URL`, `DB_LAN_URL`,
`DB_DO_URL`. Passwords must be URL-encoded (`\` = `%5C`, `@` = `%40`).

## Not in here (do by hand)

- SSH keys (`~/.local/keys/ssh`) and `~/.ssh/config`. Keys never go in git.
- `git config --global user.name / user.email`
- .NET SDKs (8, 10)
- Windows side: `%UserProfile%\.wslconfig` with `[wsl2] networkingMode=mirrored`
