# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for macOS development. Supports both automated installation via scripts and selective manual copying of configurations.

## Commands

### Setup & Update Scripts

```bash
# Full installation on fresh macOS machine
./setup.sh

# Preview what would be installed (no changes)
./setup.sh --dry-run

# Install and configure macOS preferences (trackpad, Finder, Dock)
./setup.sh --configure-macos

# Update all software (Homebrew, Oh My Zsh, language runtimes)
./update.sh

# Update with aggressive cleanup (old versions, caches)
./update.sh --cleanup
```

Both scripts are idempotent and safe to re-run.

### Brewfile Commands

```bash
# Install packages from Brewfile
brew bundle install

# Check what's missing from Brewfile
brew bundle check

# Remove packages not in Brewfile (use with caution!)
brew bundle cleanup --force

# Add currently installed package to Brewfile
brew bundle dump --describe
```

## Architecture

### Automated Scripts

**setup.sh** - Full environment provisioning:
- Installs Homebrew packages via `Brewfile` using `brew bundle install`
- Environment auto-detection: username, GitHub user from git config, SSH key location
- Customizes dotfiles by replacing `/Users/josh` with `$HOME` before symlinking
- Creates symlinks from temp customized files to `~/.zshrc` and `~/.emacs.d/init.el`
- Sets up language environments: Ruby via rbenv, Rust via rustup, Haskell via GHCup

**update.sh** - Maintenance script:
- Syncs Brewfile packages with `brew bundle install`
- Updates Homebrew packages and casks with `brew upgrade`
- Optionally removes packages not in Brewfile with `brew bundle cleanup --cleanup` flag
- Updates Oh My Zsh non-interactively
- Checks for newer Ruby versions via rbenv
- Updates Rust via rustup, Haskell via ghcup

**Brewfile** - Homebrew package manifest:
- Single source of truth for all Homebrew formulae and casks
- Organized by category: Development Tools, CLI Tools, Media Processing, etc.
- Optional packages commented out (steam, youtube-downloader)

### Configuration Files

**.zshrc** - Oh My Zsh with "dst" theme, plugins: git, brew, common-aliases, macos
- Key functions: `brewup()`, `enc()`/`dec()` (GPG encryption), `clone()`, `whisper()`
- Initializes: rbenv (Ruby), GHCup (Haskell), opam (OCaml), Deno

**init.el** - Emacs with Evil mode (Vim keybindings), leader key `,`
- Nord theme, use-package for package management
- Org mode agenda file: `~/notes/logs-and-notes/log.org`
- Key bindings: `,ff` (find-file), `,gs` (magit), `,oa` (org-agenda), F7 (edit init.el)

**nord.itermcolors** - iTerm2 color scheme (plist XML)

## Key Design Decisions

- **Brewfile for package management**: Single source of truth for all Homebrew packages, avoiding duplicate definitions in shell scripts
- **Nord theme consistency**: Applied across all tools (Emacs, iTerm2, VSCode)
- **Vim keybindings everywhere**: Evil mode in Emacs for consistent editing experience
- **Path customization at install time**: Replaces hardcoded `/Users/josh` with `$HOME` before symlinking
- **Symlinks to temp files**: Rather than direct links to repo (allows per-machine customization)