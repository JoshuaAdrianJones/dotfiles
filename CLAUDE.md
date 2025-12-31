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

## Architecture

### Automated Scripts

**setup.sh** - Full environment provisioning:
- Package lists defined in `FORMULAE` and `CASKS` arrays (setup.sh:50-91)
- Environment auto-detection: username, GitHub user from git config, SSH key location (setup.sh:189-217)
- Customizes dotfiles by replacing `/Users/josh` with `$HOME` before symlinking (setup.sh:398-447)
- Creates symlinks from temp customized files to `~/.zshrc` and `~/.emacs.d/init.el`
- Sets up language environments: Ruby via rbenv, Rust via rustup, Haskell via GHCup

**update.sh** - Maintenance script:
- Updates Homebrew packages and casks
- Updates Oh My Zsh non-interactively
- Checks for newer Ruby versions via rbenv
- Updates Rust via rustup, Haskell via ghcup

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

- Nord theme consistency across all tools (Emacs, iTerm2, VSCode)
- Vim keybindings everywhere possible (Evil mode in Emacs)
- Dotfiles customized at install time by replacing hardcoded paths with `$HOME`
- Symlinks to temp files rather than direct links to repo (allows customization per-machine)