# dotfiles

> Personal macOS development environment configurations

Configuration files for Zsh, Emacs, and iTerm2 with Nord theme consistency.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/JoshuaAdrianJones/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run full installation (idempotent, safe to re-run)
./setup.sh

# Or preview what would be installed first
./setup.sh --dry-run
```

The setup script installs Xcode CLT, Homebrew, Oh My Zsh, development tools, language environments (Ruby, Rust, Haskell, Node, Python), and symlinks customized dotfiles.

## Updating

```bash
# Update Homebrew, Oh My Zsh, and language runtimes
./update.sh

# Update with aggressive cleanup (old versions, caches)
./update.sh --cleanup
```

## What's Included

| File | Description |
|------|-------------|
| `.zshrc` | Oh My Zsh config with dst theme, aliases, utility functions (brewup, enc/dec, clone) |
| `init.el` | Emacs with Evil mode, Nord theme, Org mode, Magit |
| `nord.itermcolors` | iTerm2 Nord color scheme |
| `setup.sh` | Automated environment provisioning |
| `update.sh` | Maintenance and updates |

## Environment

| Component | Choice |
|-----------|--------|
| Primary Editor | VSCode |
| Org Mode & Writing | Emacs with Evil mode |
| Terminal | iTerm2 + Zsh + Oh My Zsh |
| Theme | Nord (everywhere) |
| Package Manager | Homebrew |

## Documentation

- **[SETUP.md](SETUP.md)** - Detailed manual installation instructions
- **[installed-software.md](installed-software.md)** - Full software inventory

## Manual Setup

You can also selectively copy configurations rather than running the automated scripts. Review the files and adapt paths/settings to match your setup.

## Evolution

- **2024**: Custom Emacs config (replacing Spacemacs), VSCode as primary editor, added Deno/Ollama/Whisper
- **2022**: M1 MacBook Pro, Nord theme adoption, iTerm2 + Zsh + Oh My Zsh

## License

MIT License - See [LICENSE](LICENSE)
