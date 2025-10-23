dotfiles 💻✨
========

The one-command setup to turn a fresh Mac into your happy dev machine. Batteries included, opinions optional.

🚀 Quick start
--------------

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.zsh
```

By default it installs EVERYTHING and runs ALL post-installs.

Prefer Just? After install: `just update`, `just services-start`, `just lint`

🧰 What gets set up
-------------------
- Homebrew + Brewfile bundle (apps, CLIs, fonts)
- Smart symlinks from `home/` → `$HOME` (idempotent)
- Post-install tasks: npm globals, Bun, fzf, SSH, macOS defaults, VS Code/Cursor, oh-my-zsh, Mackup backups
- Handy helpers: `bin/services`, `bin/update`, `Justfile` recipes

🧪 Developer tools (highlights)
-------------------------------
- 🛠️ Dev CLI: `just`, `direnv`, `zoxide`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`
- 🐍/🦫/🟦 Runtimes & tooling: `python`, `node`, `uv`, `go` + tools (`golangci-lint`, `delve`, `sqlc`)
- 🗄️ Databases: `postgresql@18`, `redis`, `pgcli`, `redisinsight`
- 🧠/🎥 AI & media: `ollama`, `ffmpeg`, `imagemagick`
- 💬 Apps & fonts: VS Code, Cursor, Raycast, JetBrains Nerd Fonts, and more

🎚️ Environment flags (opt-out toggles)
--------------------------------------
Defaults: everything runs. Use SKIP_* to turn things off.

- `INSTALL_PROFILE` (optional): choose profile-specific setup. Example: `INSTALL_PROFILE=work`.
- `DRY_RUN=1`: link step prints planned actions, makes no changes.
- `BREW_BUNDLE_CLEANUP=1`: remove formulae/casks not in Brewfile after bundling.
- `CI=1`: non-interactive defaults in some steps.
- `SKIP_FZF_SETUP=1`: don’t set up fzf keybindings/completions.
- `SKIP_SSH_SETUP=1`: don’t generate key/add to agent.
- `SKIP_MACOS_TWEAKS=1`: don’t apply macOS defaults.
- `SKIP_VSCODE_SETUP=1`: don’t import VS Code/Cursor settings.
- `SKIP_CURSOR_SETUP=1`: don't link Cursor configs or install extensions.
- `SKIP_OHMYZSH_SETUP=1`: don't install oh-my-zsh.
- `SKIP_MACKUP_SETUP=1`: don't configure Mackup backups.
- `INSTALL_SECURITY_TOOLS=1`: install additional security/penetration testing tools.

🗂️ Project layout
-----------------
- `install.zsh`: Orchestrates setup steps with sudo keepalive and summaries.
- `lib/xcode.zsh`: Prompts to install Xcode Command Line Tools on macOS (Step 0).
- `lib/bootstrap.zsh`: Installs/updates Homebrew and persists shellenv.
- `lib/brew.zsh`: Runs `brew bundle` for the selected Brewfile.
- `lib/link.zsh`: Creates symlinks from `home/` to `$HOME` (profile-aware).
- `lib/post_install.zsh`: Creates local files like `.gitconfig_local`.
- `lib/post_install_npm.zsh`: Installs useful npm globals (corepack-enabled).
- `lib/post_install_bun.zsh`: Installs Bun via official installer.
- `lib/post_install_fzf.zsh`: Sets up fzf keybindings/completions.
- `lib/post_install_ssh.zsh`: SSH bootstrap.
- `lib/macos_defaults.zsh`: macOS defaults.
- `lib/post_install_vscode.zsh`: VS Code/Cursor setup.
- `lib/post_install_cursor.zsh`: Cursor global config and extensions.
- `lib/post_install_ohmyzsh.zsh`: oh-my-zsh install (keeps your linked `.zshrc`).
- `lib/post_install_mackup.zsh`: Mackup config + scheduled backups.
- `lib/post_install_security.zsh`: Security/penetration testing tools installation.
- `home/`: Files to link into `$HOME`; may contain profile subfolders.
- Helpers: `bin/services`, `bin/update`, `bin/lint`, `bin/cleanup`, `Justfile`.

🧑‍🍳 Recipes (Just)
-------------------
- `just update` → brew update/upgrade/cleanup + language tool updates
- `just services-start` / `just services-stop` → manage `postgresql@18` + `redis`
- `just lint` → zsh syntax checks (+ shellcheck if available)
- `just cleanup` → unlink repo-managed symlinks from `$HOME`

📝 Profiles
-----------
- Set `INSTALL_PROFILE=work` to use `Brewfile.work` (i0f2 present) and `home/work/` overlay.
- Default falls back to root `Brewfile` and `home/`.

🧯 Troubleshooting
------------------
- “command not found: code” → In VS Code, run Command Palette: “Shell Command: Install 'code' command in PATH”.
- “Xcode Command Line Tools prompt popped up” → Finish install, then rerun `./install.zsh`.
- Apple Silicon + Intel-only tools → `softwareupdate --install-rosetta --agree-to-license`.
- Brewfile reproducibility → commit `Brewfile.lock.json` (use `brew bundle lock`).

🔒 Safety notes
---------------
- Symlink step is idempotent and respects `DRY_RUN=1`.
- Feature scripts run by default; use SKIP_* flags to opt out.

🗄️ Backups (Mackup)
--------------------
- Config: `~/.mackup.cfg` (we set storage to iCloud by default; change as you like).
- A LaunchAgent runs `mackup backup --force` at login and every 24h.
- Logs: `~/Library/Logs/mackup-backup.log`.

📜 License
----------
Apache 2.0. See `LICENSE`.
