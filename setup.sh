#!/usr/bin/env bash
#
# setup.sh - Automated dotfiles installation for macOS
#
# Usage: ./setup.sh [OPTIONS]
#
# OPTIONS:
#   --configure-macos     Apply macOS system preferences (trackpad, finder, dock)
#   --dry-run            Show what would be installed without executing
#   -h, --help           Show this help message
#
# This script will:
#   - Install Xcode Command Line Tools, Homebrew, and Oh My Zsh
#   - Install all Homebrew packages and applications
#   - Customize and symlink dotfiles (.zshrc, init.el)
#   - Set up language environments (Ruby, Rust, Haskell, Node, Python)
#   - Create necessary directories
#
# The script is idempotent and safe to re-run.
#

set -e  # Exit on error

# ============================================================================
# CONSTANTS & CONFIGURATION
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
TEMP_ZSHRC="/tmp/.zshrc.custom.$$"
TEMP_INIT_EL="/tmp/init.el.custom.$$"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
CONFIGURE_MACOS=false
DRY_RUN=false

# Tracking
FAILED_PACKAGES=()
INSTALLED_FORMULAE_COUNT=0
INSTALLED_CASKS_COUNT=0

# Package lists
FORMULAE=(
    git
    git-lfs
    node
    python
    rbenv
    ruby-build
    emacs
    gnupg
    jq
    wget
    cmake
    deno
    ffmpeg
    imagemagick
    flac
    lame
    opam
    r
)

CASKS=(
    iterm2
    visual-studio-code
    rectangle
    karabiner-elements
    obsidian
    firefox
    google-chrome
    vlc
    spotify
    appcleaner
    hammerspoon
    slack
    docker
    ollama
)

OPTIONAL_CASKS=(
    steam
    youtube-downloader
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

run_or_dry() {
    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would execute: $*"
        return 0
    else
        "$@"
    fi
}

show_help() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# \?//'
    exit 0
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --configure-macos)
                CONFIGURE_MACOS=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                ;;
        esac
    done
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

preflight_checks() {
    log_info "Running pre-flight checks..."

    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script only works on macOS"
        exit 1
    fi
    log_success "Running on macOS $(sw_vers -productVersion)"

    # Check disk space (warn if less than 5GB)
    local available=$(df -g / | awk 'NR==2 {print $4}')
    if [[ $available -lt 5 ]]; then
        log_warning "Low disk space: ${available}GB available (recommend at least 5GB)"
    else
        log_success "Sufficient disk space: ${available}GB available"
    fi

    # Check internet connectivity
    if ! ping -c 1 github.com &>/dev/null; then
        log_error "No internet connection detected"
        exit 1
    fi
    log_success "Internet connection verified"

    echo ""
}

# ============================================================================
# ENVIRONMENT DETECTION
# ============================================================================

detect_environment() {
    log_info "Detecting environment..."

    # Username (always use current user)
    DETECTED_USER="$(whoami)"
    log_success "Username: $DETECTED_USER"

    # GitHub username
    GITHUB_USER=$(git config user.name 2>/dev/null || echo "$DETECTED_USER")
    log_success "GitHub username: $GITHUB_USER (from git config)"

    # SSH key detection
    if [[ -f "$HOME/.ssh/github" ]]; then
        SSH_KEY="$HOME/.ssh/github"
    elif [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        SSH_KEY="$HOME/.ssh/id_ed25519"
    elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
        SSH_KEY="$HOME/.ssh/id_rsa"
    else
        SSH_KEY=""
        log_warning "No SSH key found (will need to create one)"
    fi

    if [[ -n "$SSH_KEY" ]]; then
        log_success "SSH key: $SSH_KEY"
    fi

    echo ""
}

# ============================================================================
# PREREQUISITES INSTALLATION
# ============================================================================

install_xcode_clt() {
    log_info "Checking Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools already installed"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install Xcode Command Line Tools"
        return 0
    fi

    log_info "Installing Xcode Command Line Tools..."
    log_info "Please complete the installation dialog..."
    xcode-select --install

    log_info "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done

    log_success "Xcode Command Line Tools installed"
}

install_homebrew() {
    log_info "Checking Homebrew..."

    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install Homebrew"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if command -v brew &>/dev/null; then
        log_success "Homebrew installed successfully"
    else
        log_error "Homebrew installation failed"
        exit 1
    fi
}

install_oh_my_zsh() {
    log_info "Checking Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh already installed"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install Oh My Zsh"
        return 0
    fi

    log_info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh installed successfully"
    else
        log_warning "Oh My Zsh installation may have failed (continuing anyway)"
    fi
}

install_prerequisites() {
    log_info "Installing prerequisites..."
    echo ""

    install_xcode_clt
    echo ""

    install_homebrew
    echo ""

    install_oh_my_zsh
    echo ""
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

install_homebrew_formulae() {
    log_info "Installing Homebrew formulae (this may take a while)..."

    local installed_list=""
    if command -v brew &>/dev/null && [[ $DRY_RUN == false ]]; then
        installed_list=$(brew list --formula 2>/dev/null || echo "")
    fi

    for formula in "${FORMULAE[@]}"; do
        if echo "$installed_list" | grep -q "^${formula}$"; then
            log_success "$formula (already installed)"
            ((INSTALLED_FORMULAE_COUNT++))
        elif [[ $DRY_RUN == true ]]; then
            log_info "[DRY RUN] Would install: $formula"
        else
            log_info "Installing $formula..."
            if brew install "$formula" &>/dev/null; then
                log_success "$formula installed"
                ((INSTALLED_FORMULAE_COUNT++))
            else
                log_warning "Failed to install $formula"
                FAILED_PACKAGES+=("$formula")
            fi
        fi
    done

    echo ""
}

install_homebrew_casks() {
    log_info "Installing Homebrew casks (GUI applications)..."

    local installed_list=""
    if command -v brew &>/dev/null && [[ $DRY_RUN == false ]]; then
        installed_list=$(brew list --cask 2>/dev/null || echo "")
    fi

    for cask in "${CASKS[@]}"; do
        if echo "$installed_list" | grep -q "^${cask}$"; then
            log_success "$cask (already installed)"
            ((INSTALLED_CASKS_COUNT++))
        elif [[ $DRY_RUN == true ]]; then
            log_info "[DRY RUN] Would install: $cask"
        else
            log_info "Installing $cask..."
            if brew install --cask "$cask" &>/dev/null; then
                log_success "$cask installed"
                ((INSTALLED_CASKS_COUNT++))
            else
                log_warning "Failed to install $cask (may not be available)"
                FAILED_PACKAGES+=("$cask")
            fi
        fi
    done

    # Try optional casks
    log_info "Attempting to install optional applications..."
    for cask in "${OPTIONAL_CASKS[@]}"; do
        if echo "$installed_list" | grep -q "^${cask}$"; then
            log_success "$cask (already installed)"
            ((INSTALLED_CASKS_COUNT++))
        elif [[ $DRY_RUN == true ]]; then
            log_info "[DRY RUN] Would try to install: $cask (optional)"
        else
            if brew install --cask "$cask" &>/dev/null; then
                log_success "$cask installed"
                ((INSTALLED_CASKS_COUNT++))
            else
                log_info "$cask not available (optional, skipping)"
            fi
        fi
    done

    echo ""
}

# ============================================================================
# CONFIGURATION CUSTOMIZATION
# ============================================================================

customize_zshrc() {
    log_info "Customizing .zshrc..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would customize .zshrc"
        return 0
    fi

    cp "$DOTFILES_DIR/.zshrc" "$TEMP_ZSHRC"

    # Replace all /Users/josh with $HOME
    sed -i.bak "s|/Users/josh|$HOME|g" "$TEMP_ZSHRC"

    # Replace GitHub username
    sed -i.bak "s|JoshuaAdrianJones|$GITHUB_USER|g" "$TEMP_ZSHRC"

    # Replace SSH key path if we found one
    if [[ -n "$SSH_KEY" ]]; then
        sed -i.bak "s|~/.ssh/github|$SSH_KEY|g" "$TEMP_ZSHRC"
    fi

    # Clean up backup files
    rm -f "${TEMP_ZSHRC}.bak"

    # Validate syntax
    if zsh -n "$TEMP_ZSHRC" 2>/dev/null; then
        log_success ".zshrc customized and validated"
    else
        log_warning ".zshrc syntax validation failed (proceeding anyway)"
    fi
}

customize_init_el() {
    log_info "Customizing init.el..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would customize init.el"
        return 0
    fi

    cp "$DOTFILES_DIR/init.el" "$TEMP_INIT_EL"

    # Replace /Users/josh with $HOME
    sed -i.bak "s|/Users/josh|$HOME|g" "$TEMP_INIT_EL"

    # Clean up backup files
    rm -f "${TEMP_INIT_EL}.bak"

    log_success "init.el customized"
}

# ============================================================================
# DOTFILE SYMLINKING
# ============================================================================

backup_file() {
    local file="$1"
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -L "$file" "$BACKUP_DIR/$(basename "$file")" 2>/dev/null || true
        log_info "Backed up $(basename "$file") to $BACKUP_DIR"
    fi
}

create_symlinks() {
    log_info "Creating symlinks for dotfiles..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would create symlinks"
        return 0
    fi

    # Backup existing files
    backup_file "$HOME/.zshrc"
    backup_file "$HOME/.emacs.d/init.el"

    # Create .emacs.d directory if needed
    mkdir -p "$HOME/.emacs.d"

    # Create symlinks (using customized temp files as source)
    ln -sf "$TEMP_ZSHRC" "$HOME/.zshrc"
    log_success "Linked .zshrc → ~/.zshrc"

    ln -sf "$TEMP_INIT_EL" "$HOME/.emacs.d/init.el"
    log_success "Linked init.el → ~/.emacs.d/init.el"

    echo ""
}

# ============================================================================
# LANGUAGE ENVIRONMENTS
# ============================================================================

setup_ruby() {
    log_info "Setting up Ruby environment..."

    if ! command -v rbenv &>/dev/null; then
        log_warning "rbenv not found, skipping Ruby setup"
        return 1
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install latest Ruby via rbenv"
        return 0
    fi

    # Get latest stable Ruby version
    local latest_ruby=$(rbenv install -l 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')

    if [[ -n "$latest_ruby" ]]; then
        log_info "Installing Ruby $latest_ruby..."
        if rbenv install "$latest_ruby" --skip-existing &>/dev/null; then
            rbenv global "$latest_ruby"
            log_success "Ruby $latest_ruby installed and set as global"
        else
            log_warning "Ruby installation failed"
        fi
    fi
}

setup_rust() {
    log_info "Setting up Rust environment..."

    if command -v rustc &>/dev/null; then
        log_success "Rust already installed ($(rustc --version | cut -d' ' -f2))"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install Rust via rustup"
        return 0
    fi

    log_info "Installing Rust..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null; then
        source "$HOME/.cargo/env" 2>/dev/null || true
        log_success "Rust installed successfully"
    else
        log_warning "Rust installation failed"
    fi
}

setup_haskell() {
    log_info "Setting up Haskell environment..."

    if command -v ghc &>/dev/null; then
        log_success "Haskell already installed (GHC $(ghc --version | awk '{print $NF}'))"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install Haskell via GHCup"
        return 0
    fi

    log_info "Installing Haskell via GHCup..."
    log_warning "GHCup installation requires user interaction, skipping automatic install"
    log_info "To install manually, run: curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh"
}

setup_node_packages() {
    log_info "Setting up Node.js packages..."

    if ! command -v npm &>/dev/null; then
        log_warning "npm not found, skipping Node package installation"
        return 1
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install TypeScript globally"
        return 0
    fi

    log_info "Installing TypeScript globally..."
    if npm install -g typescript &>/dev/null; then
        log_success "TypeScript installed globally"
    else
        log_warning "TypeScript installation failed"
    fi
}

setup_python_packages() {
    log_info "Setting up Python packages..."

    if ! command -v python3 &>/dev/null; then
        log_warning "Python not found, skipping pip/pipx setup"
        return 1
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would install pipx"
        return 0
    fi

    if ! command -v pipx &>/dev/null; then
        log_info "Installing pipx..."
        if python3 -m pip install --user pipx &>/dev/null; then
            python3 -m pipx ensurepath &>/dev/null || true
            log_success "pipx installed"
        else
            log_warning "pipx installation failed"
        fi
    else
        log_success "pipx already installed"
    fi
}

setup_language_environments() {
    log_info "Setting up language environments..."
    echo ""

    setup_ruby
    echo ""

    setup_rust
    echo ""

    setup_haskell
    echo ""

    setup_node_packages
    echo ""

    setup_python_packages
    echo ""
}

# ============================================================================
# POST-INSTALLATION
# ============================================================================

create_directories() {
    log_info "Creating necessary directories..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would create directories"
        return 0
    fi

    mkdir -p "$HOME/notes/logs-and-notes"
    mkdir -p "$HOME/Projects"

    # Create org file if it doesn't exist
    if [[ ! -f "$HOME/notes/logs-and-notes/log.org" ]]; then
        touch "$HOME/notes/logs-and-notes/log.org"
        log_success "Created ~/notes/logs-and-notes/log.org"
    fi

    log_success "Directories created"
}

setup_ssh_agent() {
    if [[ -z "$SSH_KEY" ]]; then
        log_warning "No SSH key found to add to ssh-agent"
        return 0
    fi

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would add SSH key to ssh-agent"
        return 0
    fi

    log_info "Adding SSH key to ssh-agent..."
    ssh-add "$SSH_KEY" &>/dev/null || true
    log_success "SSH key added to ssh-agent"
}

# ============================================================================
# MACOS PREFERENCES
# ============================================================================

configure_macos_preferences() {
    if [[ $CONFIGURE_MACOS == false ]]; then
        return 0
    fi

    log_info "Configuring macOS system preferences..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would configure macOS preferences"
        return 0
    fi

    # Enable tap to click for trackpad
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    log_success "Enabled tap to click"

    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    log_success "Enabled showing hidden files in Finder"

    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true
    log_success "Enabled path bar in Finder"

    # Auto-hide Dock
    defaults write com.apple.dock autohide -bool true
    log_success "Enabled Dock auto-hide"

    # Restart affected applications
    killall Finder &>/dev/null || true
    killall Dock &>/dev/null || true

    log_success "macOS preferences configured"
    echo ""
}

# ============================================================================
# SUMMARY & NEXT STEPS
# ============================================================================

print_summary() {
    echo ""
    echo "========================================="
    log_success "  Dotfiles Installation Complete!"
    echo "========================================="
    echo ""

    log_info "Installed:"
    echo "  - Homebrew packages: $INSTALLED_FORMULAE_COUNT"
    echo "  - GUI applications: $INSTALLED_CASKS_COUNT"
    if command -v ruby &>/dev/null; then
        echo "  - Ruby: $(ruby --version | cut -d' ' -f2)"
    fi
    if command -v rustc &>/dev/null; then
        echo "  - Rust: $(rustc --version | cut -d' ' -f2)"
    fi
    if command -v node &>/dev/null; then
        echo "  - Node.js: $(node --version)"
    fi
    echo ""

    log_info "Configuration:"
    echo "  - .zshrc linked to ~/.zshrc"
    echo "  - init.el linked to ~/.emacs.d/init.el"
    if [[ -d "$BACKUP_DIR" ]] && [[ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo "  - Backups saved to $BACKUP_DIR"
    fi
    echo ""

    if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
        log_warning "Failed Packages (optional):"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            echo "  - $pkg"
        done
        echo ""
    fi

    log_info "Next Steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Import iTerm2 Nord theme:"
    echo "     iTerm2 → Preferences → Profiles → Colors → Import → $DOTFILES_DIR/nord.itermcolors"
    if [[ -n "$SSH_KEY" ]]; then
        echo "  3. Add SSH key to GitHub: https://github.com/settings/keys"
        echo "     Copy public key: cat ${SSH_KEY}.pub | pbcopy"
    else
        echo "  3. Create SSH key and add to GitHub:"
        echo "     ssh-keygen -t ed25519 -C \"your_email@example.com\""
        echo "     cat ~/.ssh/id_ed25519.pub | pbcopy"
        echo "     https://github.com/settings/keys"
    fi
    echo "  4. (Optional) Install VSCode Nord theme:"
    echo "     code --install-extension arcticicestudio.nord-visual-studio-code"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Parse arguments
    parse_arguments "$@"

    # Show header
    echo ""
    log_info "========================================="
    log_info "  Dotfiles Setup Script"
    log_info "========================================="
    echo ""

    if [[ $DRY_RUN == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Run installation steps
    preflight_checks
    detect_environment
    install_prerequisites
    install_homebrew_formulae
    install_homebrew_casks
    customize_zshrc
    customize_init_el
    create_symlinks
    setup_language_environments
    create_directories
    setup_ssh_agent
    configure_macos_preferences

    # Show summary
    print_summary

    # Clean exit
    if [[ $DRY_RUN == false ]]; then
        log_success "Setup complete!"
    fi
}

# Run main function with all arguments
main "$@"
