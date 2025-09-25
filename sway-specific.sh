#!/usr/bin/env sh
#
# sway-specific.sh - Floating terminal bookmark browser for Sway
# Uses fzf in a floating terminal window for bookmark selection
#
# Sway Configuration Required:
# Add this to your Sway config (e.g., ~/.config/sway/config.d/98-application-defaults.conf):
#   for_window [app_id="floating_shell"] floating enable, border pixel 1, sticky enable
#   for_window [class="floating_shell"] floating enable, border pixel 1, sticky enable
#

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$0")"

# Source common functions
# shellcheck source=./bookmarkstash-common.sh
. "$SCRIPT_DIR/bookmarkstash-common.sh"

# Initialize configuration
init_bookmarkstash

# Check if we're running under Sway
if [ -z "$SWAYSOCK" ]; then
    echo "Warning: Not running under Sway, but continuing anyway..." >&2
fi

# Force fzf as menu system for this script
export BOOKMARKSTASH_MENU_SYSTEM="fzf"

# Check dependencies
if ! check_dependencies "" browser; then
    exit 1
fi

if ! command_exists fzf; then
    echo "Error: fzf not found. Please install fzf for this script." >&2
    exit 1
fi

# Get bookmark manager path
manager_path=$(get_bookmark_manager_path)

# Get browser
browser=$(get_browser)
if [ -z "$browser" ]; then
    echo "Error: No suitable browser found" >&2
    exit 1
fi

debug_print "Using browser: $browser"

# Check if floating mode is enabled
if is_floating_mode; then
    # Floating terminal mode
    debug_print "Using floating terminal mode"

    # Check for floating terminal
    floating_terminal=$(get_floating_terminal)
    if [ -z "$floating_terminal" ]; then
        echo "Error: No suitable floating terminal found" >&2
        echo "Please install one of: footclient, foot, alacritty, kitty, wezterm, gnome-terminal" >&2
        exit 1
    fi

    debug_print "Using floating terminal: $floating_terminal"
else
    # Regular terminal mode (fallback)
    debug_print "Using regular terminal mode"
fi

# Function to browse bookmarks by title
browse_by_title() {
    local titles
    titles=$(python3 "$manager_path" titles 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$titles" ]; then
        echo "Error: Failed to get bookmark titles or no bookmarks found" >&2
        return 1
    fi

    local selected_title
    if is_floating_mode; then
        selected_title=$(echo "$titles" | launch_floating_fzf "Select bookmark title")
    else
        selected_title=$(echo "$titles" | fzf --prompt="Select bookmark title> " ${BOOKMARKSTASH_FZF_ARGS:-})
    fi

    if [ -z "$selected_title" ]; then
        echo "No title selected" >&2
        return 1
    fi

    debug_print "Selected title: $selected_title"

    # Get URL for the selected title
    local url
    url=$(python3 "$manager_path" search "$selected_title" 2>/dev/null | head -n 1)
    if [ -z "$url" ]; then
        echo "Error: No URL found for title '$selected_title'" >&2
        return 1
    fi

    debug_print "Opening URL: $url"
    open_bookmark "$url" "$selected_title"
}

# Function to browse bookmarks by tag
browse_by_tag() {
    local all_tags
    all_tags=$(python3 "$manager_path" tags 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$all_tags" ]; then
        echo "Error: Failed to get bookmark tags or no bookmarks found" >&2
        return 1
    fi

    local selected_tag
    if is_floating_mode; then
        selected_tag=$(echo "$all_tags" | launch_floating_fzf "Select bookmark tag")
    else
        selected_tag=$(echo "$all_tags" | fzf --prompt="Select bookmark tag> " ${BOOKMARKSTASH_FZF_ARGS:-})
    fi

    if [ -z "$selected_tag" ]; then
        echo "No tag selected" >&2
        return 1
    fi

    debug_print "Selected tag: $selected_tag"

    # Get titles for the bookmarks with this tag
    local bookmark_titles
    bookmark_titles=$(python3 "$manager_path" search --tag "$selected_tag" 2>/dev/null | grep -v "^URL:" | sed 's/^Title: //')
    if [ -z "$bookmark_titles" ]; then
        echo "Error: Failed to get bookmark titles for tag '$selected_tag'" >&2
        return 1
    fi

    local selected_title
    if is_floating_mode; then
        selected_title=$(echo "$bookmark_titles" | launch_floating_fzf "Select bookmark from $selected_tag")
    else
        selected_title=$(echo "$bookmark_titles" | fzf --prompt="Select bookmark from $selected_tag> " ${BOOKMARKSTASH_FZF_ARGS:-})
    fi

    if [ -z "$selected_title" ]; then
        echo "No bookmark selected" >&2
        return 1
    fi

    debug_print "Selected bookmark: $selected_title"

    # Get URL for the selected bookmark
    local url
    url=$(python3 "$manager_path" search "$selected_title" 2>/dev/null | head -n 1)
    if [ -z "$url" ]; then
        echo "Error: No URL found for bookmark '$selected_title'" >&2
        return 1
    fi

    debug_print "Opening URL: $url"
    open_bookmark "$url" "$selected_title"
}

# Function to search all bookmarks
search_all() {
    # Get all bookmarks in a nice format for searching
    local all_bookmarks
    all_bookmarks=$(python3 "$manager_path" list 2>/dev/null | sed -n '/^Title: /s/^Title: //p')
    if [ -z "$all_bookmarks" ]; then
        echo "Error: No bookmarks found" >&2
        return 1
    fi

    local selected_title
    if is_floating_mode; then
        selected_title=$(echo "$all_bookmarks" | launch_floating_fzf "Search all bookmarks")
    else
        selected_title=$(echo "$all_bookmarks" | fzf --prompt="Search all bookmarks> " ${BOOKMARKSTASH_FZF_ARGS:-})
    fi

    if [ -z "$selected_title" ]; then
        echo "No bookmark selected" >&2
        return 1
    fi

    debug_print "Selected bookmark: $selected_title"

    # Get URL for the selected bookmark
    local url
    url=$(python3 "$manager_path" search "$selected_title" 2>/dev/null | head -n 1)
    if [ -z "$url" ]; then
        echo "Error: No URL found for bookmark '$selected_title'" >&2
        return 1
    fi

    debug_print "Opening URL: $url"
    open_bookmark "$url" "$selected_title"
}

# Function to open bookmark in browser
open_bookmark() {
    local url="$1"
    local title="$2"

    if ! command -v "$browser" >/dev/null 2>&1; then
        echo "Error: Browser '$browser' not found" >&2
        return 1
    fi

    "$browser" "$url" >/dev/null 2>&1 &
    echo "Opened '$title' in $browser"
}

# Main menu function
show_main_menu() {
    local menu_options="Browse by Title
Browse by Tag
Search All
Add Bookmark
Exit"

    local selected_option
    if is_floating_mode; then
        selected_option=$(echo "$menu_options" | launch_floating_fzf "BookmarkStash - Choose Action")
    else
        selected_option=$(echo "$menu_options" | fzf --prompt="BookmarkStash - Choose Action> " ${BOOKMARKSTASH_FZF_ARGS:-})
    fi

    case "$selected_option" in
        "Browse by Title")
            browse_by_title
            ;;
        "Browse by Tag")
            browse_by_tag
            ;;
        "Search All")
            search_all
            ;;
        "Add Bookmark")
            add_bookmark
            ;;
        "Exit"|"")
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option: $selected_option" >&2
            return 1
            ;;
    esac
}

# Function to add bookmark (simplified version)
add_bookmark() {
    echo "Add Bookmark functionality:"
    echo "For full bookmark adding with clipboard integration, use: ./add-bookmark.sh"
    echo "Or use command line: python3 $manager_path add <url> <title> <tag>"

    # Wait for user to read the message
    if is_floating_mode; then
        sleep 3
    else
        printf "Press Enter to continue..."
        read -r _
    fi
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sway-specific bookmark browser using fzf in floating terminal mode.

Options:
  -h, --help     Show this help message
  -t, --title    Browse by bookmark title
  -g, --tag      Browse by bookmark tag
  -s, --search   Search all bookmarks
  -f, --floating Enable floating terminal mode (overrides config)

Configuration:
  Set BOOKMARKSTASH_FLOATING=1 in your config to enable floating mode by default.

  Floating terminal options:
    BOOKMARKSTASH_FLOATING_TERMINAL=footclient
    BOOKMARKSTASH_FLOATING_WIDTH=82
    BOOKMARKSTASH_FLOATING_HEIGHT=25

  Sway Configuration Required:
    Add to ~/.config/sway/config.d/98-application-defaults.conf:
    for_window [app_id="floating_shell"] floating enable, border pixel 1, sticky enable
    for_window [class="floating_shell"] floating enable, border pixel 1, sticky enable

Examples:
  $0                    # Show main menu
  $0 --title            # Browse by title
  $0 --tag              # Browse by tag
  $0 --floating --search # Force floating mode and search
EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -t|--title)
        browse_by_title
        exit $?
        ;;
    -g|--tag)
        browse_by_tag
        exit $?
        ;;
    -s|--search)
        search_all
        exit $?
        ;;
    -f|--floating)
        export BOOKMARKSTASH_FLOATING=1
        shift
        # Re-run with remaining arguments
        exec "$0" "$@"
        ;;
    "")
        # No arguments, show main menu
        show_main_menu
        ;;
    *)
        echo "Unknown option: $1" >&2
        echo "Use $0 --help for usage information" >&2
        exit 1
        ;;
esac