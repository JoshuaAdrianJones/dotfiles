# dotfiles

> Personal macOS M1 development environment configurations

Configuration files for Zsh, Emacs, and iTerm2 with Nord theme consistency.

## Quick Start

1. Review the configuration files
2. Copy sections you find useful to your own dotfiles
3. Adapt paths and personal settings to match your setup

**Note**: This repository is designed for selective copying, not automated installation.

## What's Included

### Shell Configuration (.zshrc)

- Oh My Zsh with "dst" theme
- Custom aliases for navigation, git, and development
- Utility functions: brewup, enc/dec, clone, whisper
- Language support: Ruby (rbenv), Haskell (GHCup), OCaml (opam), Deno

### Emacs Configuration (init.el)

- Evil mode (Vim keybindings) with "," leader key
- Org mode for notes and task management
- Nord theme for visual consistency
- Magit for Git integration
- Writeroom mode for distraction-free writing

### Terminal Theme (nord.itermcolors)

- Nord color scheme for iTerm2
- Maintains visual consistency across tools

## Environment

- **OS**: macOS M1 MacBook Pro
- **Primary Editor**: VSCode
- **Org Mode & Writing**: Emacs with Evil mode
- **Terminal**: iTerm2 + Zsh + Oh My Zsh
- **Theme**: Nord everywhere
- **Package Manager**: Homebrew

## Setup Guide

See [SETUP.md](SETUP.md) for detailed installation and configuration instructions.

## Evolution

### 2024

- Switched from Spacemacs to custom Emacs config
- VSCode primary editor, Emacs for org-mode only
- Added Deno, Ollama, Whisper to workflow

### 2022

- M1 MacBook Pro
- Adopted Nord theme across all tools
- iTerm2 + Zsh + Oh My Zsh

## License

MIT License - See [LICENSE](LICENSE)
