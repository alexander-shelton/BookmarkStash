# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BookmarkStash is a simple command-line bookmark manager written in Python that stores URLs, titles, and tags in a JSON file. The project includes shell scripts for integration with rofi (a dmenu replacement) on Linux systems for quick bookmark access.

## Core Architecture

### Main Components
- **bookmark_manager.py**: Core Python application with BookmarkManager class that handles all bookmark operations
- **Data Storage**: JSON file at `~/.bookmarks.json` (configurable via --file argument)
- **Shell Scripts**: Three integration scripts for GUI interaction via rofi

### Data Model
Bookmarks are stored as JSON objects with three fields:
- `url`: The bookmark URL (validated, case-insensitive for duplicates)
- `title`: Display title (required, used for searching/filtering)
- `tag`: Single tag for categorization (required, used for filtering)

## Development Commands

### Running the Application
```bash
# Basic usage - shows help if no command provided
python3 bookmark_manager.py

# Add a bookmark
python3 bookmark_manager.py add "https://example.com" "Example Site" "tech"

# List all bookmarks
python3 bookmark_manager.py list

# List by specific tag or title
python3 bookmark_manager.py list --tag "github"
python3 bookmark_manager.py list --title "GitHub"

# Search bookmarks
python3 bookmark_manager.py search "python"
python3 bookmark_manager.py search --tag "web"

# Delete bookmarks
python3 bookmark_manager.py delete --url "https://example.com"
python3 bookmark_manager.py delete --title "Example Site"

# Get statistics
python3 bookmark_manager.py stats

# List all tags or titles
python3 bookmark_manager.py tags
python3 bookmark_manager.py titles
```

### GUI Integration Scripts
These scripts provide flexible graphical interfaces for bookmark management with automatic dependency detection and cross-platform support:

```bash
# Add bookmark from clipboard (auto-detects clipboard manager and menu system)
./add-bookmark.sh

# Browse bookmarks by title
./display_bookmarks_by_title.sh

# Browse bookmarks by tag
./display_bookmarks_by_tags.sh
```

**Supported Menu Systems**: rofi (default), dmenu, fzf
**Supported Clipboard Managers**: wl-paste (Wayland), xclip (X11), pbpaste (macOS)
**Supported Browsers**: Auto-detects Firefox, Chrome, Chromium, Brave, Opera, Vivaldi

### Configuration Help
View all available configuration options:
```bash
# Source the common library to access help
. ./bookmarkstash-common.sh && show_env_help
```

### Testing the Application
```bash
# Test basic functionality
python3 bookmark_manager.py stats

# Test with specific data file
python3 bookmark_manager.py --file test_bookmarks.json add "https://test.com" "Test" "test"
```

## Code Style and Conventions

- **Python Version**: Python 3 (uses type hints, f-strings)
- **Style**: Clean, well-documented functions with docstrings
- **Error Handling**: Comprehensive validation with user-friendly error messages
- **CLI Interface**: Uses argparse with subcommands and help text
- **File I/O**: JSON with UTF-8 encoding, graceful error handling for missing/corrupt files

## Key Implementation Details

### BookmarkManager Class Methods
- **Data persistence**: `_load_bookmarks()` and `_save_bookmarks()`
- **Validation**: `_validate_url()` checks URL format
- **Search/Filter**: Methods support exact matching for titles/tags, case-insensitive
- **Duplicate handling**: URLs are checked for uniqueness (case-insensitive)
- **Atomic operations**: Save operations are atomic - revert on failure

### Shell Script Configuration and Dependencies
The GUI scripts are now flexible and configurable:

**Configuration Options**:
- Environment variables for all settings
- Optional config file: `~/.config/bookmarkstash/config`
- Copy `config.example` to get started with customization

**Auto-detected Dependencies** (with graceful fallbacks):
- **Menu Systems**: rofi (default), dmenu, fzf
- **Clipboard Managers**: wl-paste (Wayland), xclip (X11), pbpaste (macOS)
- **Browsers**: Firefox, Chrome, Chromium, Brave, Opera, Vivaldi (prioritizes currently running browsers)

**Key Configuration Variables**:
```bash
BOOKMARKSTASH_MANAGER_PATH    # Path to bookmark_manager.py
BOOKMARKSTASH_BROWSER         # Preferred browser (auto-detected if not set)
BOOKMARKSTASH_MENU_SYSTEM     # rofi, dmenu, or fzf (default: rofi)
BOOKMARKSTASH_ROFI_ARGS       # Custom rofi styling/options
BOOKMARKSTASH_DEBUG           # Set to '1' for debug output
```

### Data File Location
- Default: `~/.bookmarks.json`
- Configurable via `--file` argument
- Automatically created if missing
- Handles JSON corruption gracefully