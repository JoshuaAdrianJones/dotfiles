#!/usr/bin/env bash
#
# update.sh - Update dotfiles and installed software
#
# Usage: ./update.sh [OPTIONS]
#
# OPTIONS:
#   --cleanup       Perform aggressive cleanup (remove old versions, caches)
#   --dry-run       Show what would be updated without executing
#   -h, --help      Show this help message
#
# This script will:
#   - Update Homebrew and all installed packages
#   - Update Oh My Zsh
#   - Update language runtimes (Ruby, Rust, Haskell, Node)
#   - Re-sync dotfiles if changed
#   - Optionally cleanup old versions and caches
#

set -e  # Exit on error

# ============================================================================
# CONSTANTS & CONFIGURATION
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
CLEANUP=false
DRY_RUN=false

# Tracking
UPDATED_ITEMS=()

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
            --cleanup)
                CLEANUP=true
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
# HOMEBREW UPDATES
# ============================================================================

update_homebrew() {
    if ! command -v brew &>/dev/null; then
        log_warning "Homebrew not installed, skipping Homebrew updates"
        return 1
    fi

    if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
        log_warning "Brewfile not found at $DOTFILES_DIR/Brewfile"
        log_info "Falling back to standard brew upgrade..."
    fi

    log_info "Updating Homebrew..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would run: brew update"
        log_info "[DRY RUN] Would run: brew upgrade"
        if [[ $CLEANUP == true ]]; then
            log_info "[DRY RUN] Would run: brew bundle cleanup --file=$DOTFILES_DIR/Brewfile"
            log_info "[DRY RUN] Would run: brew cleanup --prune=all"
        fi
        return 0
    fi

    # Update Homebrew itself
    if brew update &>/dev/null; then
        log_success "Homebrew updated"
        UPDATED_ITEMS+=("Homebrew")
    else
        log_warning "Homebrew update failed"
    fi

    # Upgrade packages from Brewfile
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        log_info "Installing/upgrading packages from Brewfile..."

        # Check what needs to be installed
        local missing_count=0
        if ! brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
            missing_count=1
        fi

        # Install any missing packages from Brewfile
        if brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock; then
            if [[ $missing_count -gt 0 ]]; then
                log_success "Brewfile packages synchronized"
                UPDATED_ITEMS+=("Brewfile packages")
            else
                log_success "All Brewfile packages already installed"
            fi
        else
            log_warning "Some Brewfile package installations may have failed"
        fi
    fi

    # Upgrade all packages (including those not in Brewfile)
    log_info "Upgrading Homebrew packages..."
    local outdated=$(brew outdated --formula | wc -l | tr -d ' ')

    if [[ $outdated -gt 0 ]]; then
        log_info "Upgrading $outdated outdated packages..."
        if brew upgrade &>/dev/null; then
            log_success "Upgraded $outdated Homebrew packages"
            UPDATED_ITEMS+=("$outdated Homebrew packages")
        else
            log_warning "Some package upgrades may have failed"
        fi
    else
        log_success "All Homebrew packages up to date"
    fi

    # Upgrade casks
    log_info "Upgrading Homebrew casks..."
    local outdated_casks=$(brew outdated --cask | wc -l | tr -d ' ')

    if [[ $outdated_casks -gt 0 ]]; then
        log_info "Upgrading $outdated_casks outdated casks..."
        if brew upgrade --cask --greedy &>/dev/null; then
            log_success "Upgraded $outdated_casks casks"
            UPDATED_ITEMS+=("$outdated_casks casks")
        else
            log_warning "Some cask upgrades may have failed"
        fi
    else
        log_success "All casks up to date"
    fi

    # Cleanup if requested
    if [[ $CLEANUP == true ]]; then
        # Clean up packages not in Brewfile
        if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
            log_info "Removing packages not in Brewfile..."
            if brew bundle cleanup --file="$DOTFILES_DIR/Brewfile" --force; then
                log_success "Removed packages not in Brewfile"
                UPDATED_ITEMS+=("Brewfile cleanup")
            else
                log_warning "Brewfile cleanup had warnings"
            fi
        fi

        # General Homebrew cleanup
        log_info "Cleaning up Homebrew caches and old versions..."
        if brew cleanup --prune=all &>/dev/null; then
            log_success "Homebrew cleanup complete"
            UPDATED_ITEMS+=("Homebrew cleanup")
        else
            log_warning "Homebrew cleanup had warnings"
        fi
    fi

    echo ""
}

# ============================================================================
# OH MY ZSH UPDATE
# ============================================================================

update_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh not installed, skipping"
        return 1
    fi

    log_info "Updating Oh My Zsh..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would update Oh My Zsh"
        return 0
    fi

    # Run omz update in non-interactive mode
    if env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/upgrade.sh" &>/dev/null; then
        log_success "Oh My Zsh updated"
        UPDATED_ITEMS+=("Oh My Zsh")
    else
        # omz might already be up to date
        log_success "Oh My Zsh is up to date"
    fi

    echo ""
}

# ============================================================================
# LANGUAGE RUNTIME UPDATES
# ============================================================================

update_ruby() {
    if ! command -v rbenv &>/dev/null; then
        log_warning "rbenv not installed, skipping Ruby update"
        return 1
    fi

    log_info "Checking for Ruby updates..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would check for latest Ruby version"
        return 0
    fi

    local current_ruby=$(rbenv global 2>/dev/null || echo "none")
    local latest_ruby=$(rbenv install -l 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')

    if [[ -n "$latest_ruby" ]] && [[ "$current_ruby" != "$latest_ruby" ]]; then
        log_info "Installing Ruby $latest_ruby..."
        if rbenv install "$latest_ruby" --skip-existing &>/dev/null; then
            rbenv global "$latest_ruby"
            log_success "Ruby updated to $latest_ruby"
            UPDATED_ITEMS+=("Ruby $latest_ruby")
        else
            log_warning "Ruby installation failed"
        fi
    else
        log_success "Ruby is up to date ($current_ruby)"
    fi

    # Cleanup old versions if requested
    if [[ $CLEANUP == true ]]; then
        log_info "Cleaning up old Ruby versions..."
        local installed_rubies=$(rbenv versions --bare | grep -v "$latest_ruby" || true)
        if [[ -n "$installed_rubies" ]]; then
            echo "$installed_rubies" | while read -r old_version; do
                rbenv uninstall -f "$old_version" &>/dev/null || true
                log_success "Removed Ruby $old_version"
            done
        fi
    fi
}

update_rust() {
    if ! command -v rustup &>/dev/null; then
        log_warning "rustup not installed, skipping Rust update"
        return 1
    fi

    log_info "Updating Rust..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would run: rustup update"
        return 0
    fi

    if rustup update &>/dev/null; then
        log_success "Rust updated"
        UPDATED_ITEMS+=("Rust")
    else
        log_warning "Rust update failed"
    fi
}

update_haskell() {
    if ! command -v ghcup &>/dev/null; then
        log_warning "ghcup not installed, skipping Haskell update"
        return 1
    fi

    log_info "Updating Haskell..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would run: ghcup upgrade"
        return 0
    fi

    if ghcup upgrade &>/dev/null; then
        log_success "GHCup updated"
        UPDATED_ITEMS+=("Haskell/GHCup")
    else
        log_warning "GHCup update failed"
    fi
}

update_node_packages() {
    if ! command -v npm &>/dev/null; then
        log_warning "npm not installed, skipping Node package updates"
        return 1
    fi

    log_info "Updating global Node packages..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would run: npm update -g"
        return 0
    fi

    if npm update -g &>/dev/null; then
        log_success "Global Node packages updated"
        UPDATED_ITEMS+=("Node packages")
    else
        log_warning "Node package update had warnings"
    fi
}

update_language_runtimes() {
    log_info "Updating language runtimes..."
    echo ""

    update_ruby
    echo ""

    update_rust
    echo ""

    update_haskell
    echo ""

    update_node_packages
    echo ""
}

# ============================================================================
# DOTFILES RE-SYNC
# ============================================================================

resync_dotfiles() {
    log_info "Checking for dotfiles updates..."

    if [[ $DRY_RUN == true ]]; then
        log_info "[DRY RUN] Would re-sync dotfiles if changed"
        return 0
    fi

    # Check if dotfiles have been updated
    local zshrc_link=$(readlink "$HOME/.zshrc" 2>/dev/null || echo "")
    local init_link=$(readlink "$HOME/.emacs.d/init.el" 2>/dev/null || echo "")

    # If symlinks point to temp files (from setup.sh), they're already synced
    if [[ -L "$HOME/.zshrc" ]] && [[ -L "$HOME/.emacs.d/init.el" ]]; then
        log_success "Dotfiles are already linked"
    else
        log_info "Dotfiles may need re-linking. Run ./setup.sh to update."
    fi

    echo ""
}

# ============================================================================
# SUMMARY
# ============================================================================

print_summary() {
    echo ""
    echo "========================================="
    log_success "  Update Complete!"
    echo "========================================="
    echo ""

    if [[ ${#UPDATED_ITEMS[@]} -gt 0 ]]; then
        log_info "Updated:"
        for item in "${UPDATED_ITEMS[@]}"; do
            echo "  - $item"
        done
    else
        log_info "Everything was already up to date!"
    fi

    echo ""
    log_info "Consider restarting your terminal for changes to take effect"
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
    log_info "  Dotfiles Update Script"
    log_info "========================================="
    echo ""

    if [[ $DRY_RUN == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Run update steps
    update_homebrew
    update_oh_my_zsh
    update_language_runtimes
    resync_dotfiles

    # Show summary
    print_summary

    # Clean exit
    if [[ $DRY_RUN == false ]]; then
        log_success "Update complete!"
    fi
}

# Run main function with all arguments
main "$@"
