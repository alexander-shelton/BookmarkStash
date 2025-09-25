#!/usr/bin/env sh
#
# BookmarkStash Installation Script
#
# This script installs BookmarkStash by:
# 1. Adding the bin/ directory to your PATH
# 2. Making scripts executable
# 3. Optionally copying config example
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$INSTALL_DIR/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarkstash"

echo "BookmarkStash Installation"
echo "========================="
echo

# Check if Python 3 is available
if ! command -v python3 >/dev/null 2>&1; then
    printf "${RED}Error: Python 3 is required but not found${NC}\n"
    printf "Please install Python 3 and try again.\n"
    exit 1
fi

# Make scripts executable
printf "Making scripts executable... "
chmod +x "$BIN_DIR"/*
printf "${GREEN}done${NC}\n"

# Create symlink for direct CLI access
printf "Creating bookmark-manager symlink... "
ln -sf "$INSTALL_DIR/lib/bookmark_manager.py" "$BIN_DIR/bookmark-manager"
chmod +x "$BIN_DIR/bookmark-manager"
printf "${GREEN}done${NC}\n"

# Check if bin directory is already in PATH
if echo "$PATH" | grep -q "$BIN_DIR"; then
    printf "${GREEN}✓${NC} bin/ directory is already in your PATH\n"
else
    printf "${YELLOW}!${NC} bin/ directory is not in your PATH\n"
    echo
    echo "To use BookmarkStash commands from anywhere, add this to your shell's config file:"
    echo
    printf "${GREEN}export PATH=\"$BIN_DIR:\$PATH\"${NC}\n"
    echo
    echo "Shell config files:"
    echo "  • Bash: ~/.bashrc or ~/.bash_profile"
    echo "  • Zsh: ~/.zshrc"
    echo "  • Fish: ~/.config/fish/config.fish"
    echo

    # Detect and offer to add to appropriate shell config
    shell_config=""
    shell_name=""

    # Check current shell first
    case "$SHELL" in
        */zsh)
            if [ -f "$HOME/.zshrc" ]; then
                shell_config="$HOME/.zshrc"
                shell_name="zsh"
            fi
            ;;
        */bash)
            if [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
                shell_name="bash"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
                shell_name="bash"
            fi
            ;;
        */fish)
            if [ -f "$HOME/.config/fish/config.fish" ]; then
                shell_config="$HOME/.config/fish/config.fish"
                shell_name="fish"
            fi
            ;;
    esac

    # Fallback to checking available files if current shell detection failed
    if [ -z "$shell_config" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            shell_config="$HOME/.zshrc"
            shell_name="zsh"
        elif [ -f "$HOME/.bashrc" ]; then
            shell_config="$HOME/.bashrc"
            shell_name="bash"
        elif [ -f "$HOME/.bash_profile" ]; then
            shell_config="$HOME/.bash_profile"
            shell_name="bash"
        elif [ -f "$HOME/.config/fish/config.fish" ]; then
            shell_config="$HOME/.config/fish/config.fish"
            shell_name="fish"
        fi
    fi

    if [ -n "$shell_config" ]; then
        printf "Would you like me to add it to your $shell_config? (y/N): "
        read -r response
        if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
            if [ "$shell_name" = "fish" ]; then
                # Fish uses different syntax
                echo >> "$shell_config"
                echo "# BookmarkStash" >> "$shell_config"
                echo "set -gx PATH \"$BIN_DIR\" \$PATH" >> "$shell_config"
            else
                # Bash/Zsh syntax
                echo >> "$shell_config"
                echo "# BookmarkStash" >> "$shell_config"
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_config"
            fi
            printf "${GREEN}✓${NC} Added to $shell_config\n"
            printf "${YELLOW}Note:${NC} You'll need to restart your shell or run: source $shell_config\n"
        fi
    fi
fi

# Create config directory and copy example
printf "\nSetting up configuration... "
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config" ] && [ -f "$INSTALL_DIR/config/config.example" ]; then
    cp "$INSTALL_DIR/config/config.example" "$CONFIG_DIR/config"
    printf "${GREEN}done${NC} (copied example config)\n"
else
    printf "${GREEN}done${NC}\n"
fi

# Test the installation
printf "\nTesting installation... "
if "$BIN_DIR/bookmark-add" --help >/dev/null 2>&1; then
    printf "${GREEN}success${NC}\n"
else
    # Check if it's a dependency issue
    if python3 "$INSTALL_DIR/lib/bookmark_manager.py" --help >/dev/null 2>&1; then
        printf "${GREEN}success${NC}\n"
    else
        printf "${RED}failed${NC}\n"
        echo "The bookmark manager script may have issues. Please check the installation."
        exit 1
    fi
fi

echo
printf "${GREEN}Installation complete!${NC}\n"
echo
echo "Available commands:"
echo "  • bookmark-add           - Add bookmark from clipboard"
echo "  • bookmark-browse-title  - Browse bookmarks by title"
echo "  • bookmark-browse-tags   - Browse bookmarks by tag"
echo "  • bookmark-manager       - Direct CLI access to all functionality"
echo
echo "Alternative CLI access:"
echo "  • python3 lib/bookmark_manager.py [command]"
echo
echo "Configuration:"
echo "  • Config file: $CONFIG_DIR/config"
echo "  • Data file: ~/.bookmarks.json (default)"
echo
printf "Run any command to get started, or see README.md for more information.\n"