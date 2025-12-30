# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for a macOS M1 development environment. The repository is not designed for automated installation but rather serves as a reference and source for selective configuration copying.

## Configuration Files

### Shell Configuration (.zshrc)
- Uses Oh My Zsh framework with the "dst" theme
- Active plugins: git, brew, common-aliases, macos
- Well-documented with header block and section markers for easy navigation
- Initializes rbenv (Ruby), GHCup (Haskell), and opam (OCaml)
- **Environment Variables**:
  - Deno installation path configured (.zshrc:30-32)
  - Ollama API base URL set to local instance (.zshrc:35)
  - pipx binary path added (.zshrc:177)
- **Utility Functions** (all well-documented with usage examples):
  - `brewup()` - Runs full Homebrew update and cleanup cycle
  - `enc()` - GPG-based AES256 file encryption
  - `dec()` - GPG file decryption
  - `clone()` - Clones repositories from JoshuaAdrianJones GitHub account
  - `del()` - Removes files/directories with `rm -rf`
  - `whisper()` - Launches whisper_menubar.py in background for voice transcription
- **Configuration Aliases**:
  - `setup`, `zshconfig`, `config` - Opens .zshrc in VSCode
  - `myrepos` - Lists all GitHub repositories via API
- **Navigation Shortcuts**:
  - `ic` - iCloud Documents folder
  - `proj` - ~/Projects
  - `dl` - ~/Downloads
  - `docs` - ~/Documents
- **Git Shortcuts**:
  - `status` - git status
  - `gp` - git pull
  - `gpp` - git push
- **Auto-Configuration**:
  - SSH key for GitHub automatically added on shell startup (.zshrc:182)

### Emacs Configuration (init.el)
- Uses `use-package` macro for package management with MELPA repository
- Well-documented with header block and section markers for easy navigation
- **Theme**: Nord theme (`nord-theme` package) for visual consistency
- **Editor Mode**: Evil mode (Vim keybindings) with leader key set to `,`
- **Key Packages**:
  - `evil` + `evil-leader` + `evil-org` + `evil-collection` - Vim emulation
  - `org` + `org-superstar` - Org mode with enhanced visuals
  - `magit` - Git interface
  - `writeroom-mode` - Distraction-free writing (width: 120)
  - `treemacs` - File tree navigator
  - `consult` + `marginalia` - Enhanced search and completions
- **Org Mode Configuration**:
  - Todo keywords: MAYBE, TODO, DOING, WAITING, DONE (color-coded)
  - Agenda file: `~/notes/logs-and-notes/log.org`
  - Timestamps logged on task completion
- **Leader Keybindings**: `,ff` (find-file), `,bb` (switch-buffer), `,gs` (magit-status), `,oa` (org-agenda), `,wr` (writeroom-mode), etc.
- **Quick Access Keys**: `F7` (edit init file), `F8` (toggle Treemacs)

### iTerm2 Configuration (nord.itermcolors)
- Nord color scheme in plist XML format
- Provides consistent dark theme matching Emacs and VSCode

### Git Configuration (.gitignore)
- Comprehensive patterns for macOS, Python, Node.js, VSCode
- Selectively includes VSCode settings: settings.json, tasks.json, launch.json, extensions.json

## Documentation Files

### README.md
- Main repository documentation in Markdown format
- Provides quick start guide and overview of configurations
- Lists all included files and their purposes
- Links to SETUP.md for detailed installation instructions
- Includes project evolution history (2022-2024)

### SETUP.md
- Comprehensive setup guide for new macOS machines
- Step-by-step installation instructions for all tools
- Code blocks with actual commands to run
- Configuration notes and customization checklist
- Troubleshooting section for common issues
- Links to download pages for all applications

## Development Environment

**Primary Editor**: VSCode (2024 preference)
**Org Mode & Writing**: Emacs with Evil mode
**Terminal**: iTerm2 + Zsh + Oh My Zsh
**Theme**: Nord theme across all tools for visual consistency
**Package Manager**: Homebrew

## Language Environments

The environment supports multiple programming languages:
- **Ruby**: Managed via rbenv (initialized in .zshrc:20)
- **Haskell**: GHCup environment (sourced in .zshrc:171)
- **OCaml**: opam package manager (initialized in .zshrc:174)
- **Deno**: JavaScript/TypeScript runtime (configured in .zshrc:30-32)
- **Node.js/TypeScript**: Documented in SETUP.md
- **Python**: Documented in SETUP.md, pipx for isolated CLI tools
- **Rust**: Documented in SETUP.md

## Key Tools & Utilities

- **Karabiner**: Key remapping (Caps Lock → Esc)
- **Rectangle**: Window management
- **Docker**: Optional containerization
- **Obsidian**: Note-taking application
- **Ollama**: Local LLM server (API configured at localhost:11434)
- **Whisper**: Voice transcription tool (custom menubar implementation)

## Usage Philosophy

Per README.md, configurations are meant to be selectively copied rather than automatically installed. Users should review files and add useful portions to their own dotfiles. This repository serves as a reference, not an automated installation tool.

The setup emphasizes:
1. Visual consistency through Nord theme everywhere
2. Vim keybindings where possible (Evil mode in Emacs)
3. Productivity-focused minimal configurations
4. Manual setup over automation for better understanding
5. Well-documented code with inline comments and section markers