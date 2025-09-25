#!/usr/bin/env sh
#
# display_bookmarks_by_tags.sh - Browse bookmarks by tag
#

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$0")"

# Source common functions
# shellcheck source=./bookmarkstash-common.sh
. "$SCRIPT_DIR/bookmarkstash-common.sh"

# Initialize configuration
init_bookmarkstash

# Check dependencies
if ! check_dependencies "" browser; then
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

# Get all bookmark tags
all_tags=$(python3 "$manager_path" tags 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$all_tags" ]; then
    echo "Error: Failed to get bookmark tags or no bookmarks found" >&2
    exit 1
fi

# Let user select a tag
selected_tag=$(show_menu "Select a bookmark tag" "$all_tags")
if [ -z "$selected_tag" ]; then
    echo "No tag selected" >&2
    exit 1
fi

debug_print "Selected tag: $selected_tag"

# Get bookmarks for the selected tag
bookmarks_with_tag=$(python3 "$manager_path" search --tag "$selected_tag" 2>/dev/null)
if [ -z "$bookmarks_with_tag" ]; then
    echo "Error: No bookmarks found for tag '$selected_tag'" >&2
    exit 1
fi

# Get titles for the bookmarks with this tag to show a nicer selection interface
bookmark_titles=$(python3 "$manager_path" list --tag "$selected_tag" 2>/dev/null | grep -v "^URL:" | sed 's/^Title: //')
if [ -z "$bookmark_titles" ]; then
    echo "Error: Failed to get bookmark titles for tag '$selected_tag'" >&2
    exit 1
fi

# Let user select a specific bookmark by title
selected_title=$(show_menu "Select a bookmark" "$bookmark_titles")
if [ -z "$selected_title" ]; then
    echo "No bookmark selected" >&2
    exit 1
fi

debug_print "Selected bookmark: $selected_title"

# Get URL for the selected bookmark
url=$(python3 "$manager_path" search --title "$selected_title" 2>/dev/null | head -n 1)
if [ -z "$url" ]; then
    echo "Error: No URL found for bookmark '$selected_title'" >&2
    exit 1
fi

debug_print "Opening URL: $url"

# Open in browser
if ! "$browser" "$url" 2>/dev/null &; then
    echo "Error: Failed to open browser" >&2
    exit 1
fi

echo "Opened '$selected_title' in $browser"
