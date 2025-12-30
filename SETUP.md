# Setup Guide

Complete setup guide for configuring a new macOS machine with these dotfiles.

## Table of Contents

- [System Preferences](#system-preferences)
- [Essential Tools](#essential-tools)
- [Development Environment](#development-environment)
- [Applications](#applications)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## System Preferences

### macOS Settings to Update

- Enable "Tap to click" in Trackpad settings
- Configure Hot Corners (Desktop & Screensaver settings)
  - Recommended: Quick access to desktop, screensaver, etc.

## Essential Tools

### Command Line Tools

#### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

Follow the command line prompts.

#### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the command line prompts and add to PATH as instructed.

### Shell Setup

#### 3. Zsh & Oh My Zsh

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### 4. Apply .zshrc Configuration

```bash
# Backup existing config
mv ~/.zshrc ~/.zshrc.backup

# Copy this repo's config
cp .zshrc ~/.zshrc

# Update username in paths (replace 'josh' with your username)
# Edit these lines:
# - Line 6: export ZSH="/Users/josh/.oh-my-zsh"
# - Line 136: GHCup path
# - Line 139: opam path
# - Line 142: pipx path
# - Line 144: ssh-add path
# - Line 92: clone function GitHub username
```

Reload your shell:

```bash
source ~/.zshrc
```

### Terminal & Editor

#### 5. iTerm2

Download from [iterm2.com](https://iterm2.com)

**Apply Nord Theme**:

1. Download theme: `nord.itermcolors` from this repo
2. iTerm2 → Preferences → Profiles → Colors
3. Color Presets → Import → Select `nord.itermcolors`
4. Select "Nord" from presets

**Set Oh My Zsh Theme**:

Already configured in `.zshrc` - uses "dst" theme

#### 6. VSCode

Download from [code.visualstudio.com](https://code.visualstudio.com)

**Extensions to Install**:

- Nord Theme: `arcticicestudio.nord-visual-studio-code`

#### 7. Emacs

```bash
brew install emacs
```

**Configuration**:

```bash
# Ensure ~/.emacs.d directory exists
mkdir -p ~/.emacs.d

# Copy init file
cp init.el ~/.emacs.d/init.el

# First launch will auto-install packages
emacs
```

**Primary Use Case**: Org mode and distraction-free writing

**Org Agenda Setup**:

Create the expected org agenda file:

```bash
mkdir -p ~/notes/logs-and-notes
touch ~/notes/logs-and-notes/log.org
```

Or update the path in `~/.emacs.d/init.el` (line 193) to point to your preferred location.

## Development Environment

### Programming Languages

#### Ruby

```bash
brew install rbenv ruby-build
rbenv install 3.2.0  # or latest stable
rbenv global 3.2.0
```

#### Node.js & TypeScript

```bash
brew install node
npm install -g typescript
```

#### Deno

```bash
brew install deno
```

#### Python

```bash
brew install python
pip3 install pipx
pipx ensurepath
```

#### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Haskell

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

#### OCaml

```bash
brew install opam
opam init
```

#### R

```bash
brew install r
```

## Applications

### Productivity

- **Rectangle**: [rectangleapp.com](https://rectangleapp.com) - Window management
  - Enable "tap to click" for best experience
- **Karabiner-Elements**: [karabiner-elements.pqrs.org](https://karabiner-elements.pqrs.org) - Key remapping
  - Recommended: Remap Caps Lock → Escape
- **Obsidian**: [obsidian.md](https://obsidian.md) - Note-taking

### Browsers

- **Firefox**: Primary browser - [mozilla.org/firefox](https://www.mozilla.org/firefox/)
- **Chrome**: For Chromecast and dev tools - [google.com/chrome](https://www.google.com/chrome/)

### Entertainment

- **Spotify**: [spotify.com/download](https://www.spotify.com/download/)
  - Note: No Mac App Store version available
- **Steam**: [steampowered.com](https://steampowered.com/)

### Optional Tools

- **Docker**: [docker.com](https://www.docker.com/products/docker-desktop) - Containerization
- **Ollama**: [ollama.ai](https://ollama.ai) - Local LLM server
  - Already configured in `.zshrc` at `http://127.0.0.1:11434`

## Configuration

### Nord Theme Everywhere

This setup uses the [Nord color scheme](https://www.nordtheme.com/) across all tools for visual consistency:

- **iTerm2**: `nord.itermcolors` (included in this repo)
- **VSCode**: Install Nord theme extension
- **Emacs**: Auto-installed via `init.el`

### SSH Keys

Generate a new SSH key if needed:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

The `.zshrc` automatically adds `~/.ssh/github` to ssh-agent on shell startup (line 144). Update this path if you use a different key name.

### Custom Zsh Functions

The `.zshrc` includes these custom functions:

- **`brewup`** - Complete Homebrew update, upgrade, and cleanup cycle
- **`enc <file>`** - Encrypt file with GPG AES256
- **`dec <file>`** - Decrypt GPG encrypted file
- **`clone <repo>`** - Clone from your GitHub account
  - Update username in `.zshrc` line 92 (currently set to JoshuaAdrianJones)
- **`whisper`** - Launch voice transcription menubar app (requires separate installation)
- **`del <file>`** - Remove files/directories with `rm -rf` (use carefully!)

### Emacs Keybindings

Evil mode is configured with `,` as the leader key. Key bindings include:

- `,ff` - Find file
- `,bb` - Switch buffer
- `,bd` - Kill buffer
- `,gs` - Magit status
- `,oa` - Org agenda
- `,wr` - Writeroom mode
- `F7` - Edit init file
- `F8` - Toggle Treemacs

See `init.el` for the complete list.

## Troubleshooting

### Emacs package installation fails

```bash
# Clear package cache
rm -rf ~/.emacs.d/elpa/
# Restart Emacs - packages will reinstall
```

### Zsh theme not loading

```bash
# Verify Oh My Zsh installation
ls ~/.oh-my-zsh
# Re-source config
source ~/.zshrc
```

### rbenv not working

```bash
# Ensure rbenv is in PATH
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### SSH key not auto-loading

Update line 144 in `.zshrc` to point to your SSH key:

```bash
ssh-add ~/.ssh/your_key_name
```

## Notes for M1 Macs

All tools listed work natively on Apple Silicon M1 chips. No Rosetta translation needed as of 2024.

## Customization Checklist

After copying these dotfiles, update the following for your personal setup:

- [ ] Username in `ZSH` path (.zshrc line 6)
- [ ] GitHub username in `clone` function (.zshrc line 92)
- [ ] SSH key path (.zshrc line 144)
- [ ] Org agenda file path (init.el line 193) or create `~/notes/logs-and-notes/log.org`
- [ ] GHCup, opam, pipx paths if username differs
- [ ] Whisper app path if you use voice transcription (.zshrc line 95)
