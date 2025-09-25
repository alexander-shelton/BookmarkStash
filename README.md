# BookmarkStash

A simple, flexible command-line bookmark manager with GUI integration for quick bookmark access and management.

## Features

- **Command-line interface** with intuitive subcommands
- **GUI integration** with popular menu systems (rofi, dmenu, fzf)
- **Cross-platform clipboard support** (Wayland, X11, macOS)
- **Flexible browser detection** (Firefox, Chrome, Brave, Opera, etc.)
- **JSON storage** with human-readable format
- **Tag-based organization** for easy categorization
- **Search and filtering** by title, tag, or URL
- **Highly configurable** with environment variables and config files

## Quick Start

1. **Install:**
   ```bash
   git clone <repository-url>
   cd BookmarkStash
   ./install.sh
   ```

2. **Add a bookmark:**
   ```bash
   bookmark-add  # From clipboard with GUI
   # OR directly:
   python3 lib/bookmark_manager.py add "https://github.com" "GitHub" "dev"
   ```

3. **Browse bookmarks:**
   ```bash
   bookmark-browse-title  # GUI browser
   bookmark-browse-tags   # Browse by tag
   ```

## Installation

### Prerequisites

**For command-line usage:**
- Python 3.6+

**For GUI integration (optional):**
- Menu system: `rofi` (recommended), `dmenu`, or `fzf`
- Clipboard manager: `wl-paste` (Wayland), `xclip` (X11), or `pbpaste` (macOS)
- Web browser: Any modern browser (auto-detected)

### Setup

**Automated Installation (Recommended):**
```bash
git clone <repository-url>
cd BookmarkStash
./install.sh
```

The install script will:
- Make all scripts executable
- Offer to add `bin/` to your PATH
- Create config directory and copy example config
- Test the installation

**Manual Installation:**
```bash
# Make scripts executable
chmod +x bin/*

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PWD/bin:$PATH"

# Create config file
mkdir -p ~/.config/bookmarkstash
cp config/config.example ~/.config/bookmarkstash/config
```

## Usage

### Command-Line Interface

#### Adding Bookmarks
```bash
# Add a bookmark with URL, title, and tag
python3 lib/bookmark_manager.py add "https://example.com" "Example Site" "web"

# URL validation ensures proper format
python3 lib/bookmark_manager.py add "example.com" "Example" "web"  # Auto-adds https://
```

#### Listing Bookmarks
```bash
# List all bookmarks
python3 lib/bookmark_manager.py list

# List bookmarks by tag
python3 lib/bookmark_manager.py list --tag "dev"

# List bookmarks by title
python3 lib/bookmark_manager.py list --title "GitHub"
```

#### Searching Bookmarks
```bash
# Search in all fields
python3 lib/bookmark_manager.py search "python"

# Search by specific tag
python3 lib/bookmark_manager.py search --tag "dev"

# Search by specific title
python3 lib/bookmark_manager.py search --title "GitHub"
```

#### Managing Bookmarks
```bash
# Delete by URL
python3 lib/bookmark_manager.py delete --url "https://example.com"

# Delete by title
python3 lib/bookmark_manager.py delete --title "Example Site"

# Get statistics
python3 lib/bookmark_manager.py stats

# List all tags
python3 lib/bookmark_manager.py tags

# List all titles
python3 lib/bookmark_manager.py titles
```

#### Custom Data File
```bash
# Use a different bookmark file
python3 lib/bookmark_manager.py --file /path/to/bookmarks.json list
```

### GUI Integration Scripts

#### Add Bookmark from Clipboard
```bash
bookmark-add
```
- Reads URL from clipboard
- Prompts for title and tag using your configured menu system
- Automatically detects clipboard manager (wl-paste, xclip, pbpaste)

#### Browse Bookmarks by Title
```bash
bookmark-browse-title
```
- Shows all bookmark titles in a searchable menu
- Opens selected bookmark in your preferred browser

#### Browse Bookmarks by Tag
```bash
bookmark-browse-tags
```
- First select a tag, then select a bookmark from that tag
- Opens selected bookmark in your preferred browser

## Configuration

### Environment Variables

Set these in your shell profile (`~/.bashrc`, `~/.zshrc`) or config file:

```bash
# Required (if not in default location)
BOOKMARKSTASH_MANAGER_PATH="/path/to/lib/bookmark_manager.py"

# Optional customizations
BOOKMARKSTASH_BROWSER="firefox"                    # Preferred browser
BOOKMARKSTASH_MENU_SYSTEM="rofi"                   # Menu system: rofi, dmenu, fzf
BOOKMARKSTASH_CLIPBOARD_CMD="wl-paste"             # Custom clipboard command
BOOKMARKSTASH_DEBUG="1"                            # Enable debug output

# Menu system styling
BOOKMARKSTASH_ROFI_ARGS="-theme gruvbox-dark -width 50"
BOOKMARKSTASH_DMENU_ARGS="-fn 'DejaVu Sans Mono-12'"
BOOKMARKSTASH_FZF_ARGS="--height=40% --layout=reverse"
```

### Config File

Create `~/.config/bookmarkstash/config`:

```bash
# Copy the example and customize
cp config/config.example ~/.config/bookmarkstash/config
```

The config file uses the same environment variable names. Settings are applied in this order:
1. Environment variables (highest priority)
2. Config file
3. Built-in defaults (lowest priority)

### View Configuration Help

```bash
# Source the common library to see all options
. lib/bookmarkstash-common.sh && show_env_help
```

## Supported Systems

### Menu Systems
- **rofi** (default) - Feature-rich application launcher
- **dmenu** - Minimalist dynamic menu
- **fzf** - Command-line fuzzy finder

### Clipboard Managers
- **wl-paste** (Wayland) - Auto-detected on Wayland sessions
- **xclip** (X11) - Auto-detected on X11 sessions
- **pbpaste** (macOS) - Auto-detected on macOS

### Browsers
Auto-detects and prioritizes currently running browsers:
- Firefox
- Google Chrome / Chromium
- Brave Browser
- Opera
- Vivaldi

## Data Storage

- **Location:** `~/.bookmarks.json` (configurable)
- **Format:** JSON with UTF-8 encoding
- **Structure:** Array of objects with `url`, `title`, `tag` fields
- **Backup:** Consider backing up your bookmark file regularly

Example bookmark file:
```json
[
    {
        "url": "https://github.com",
        "title": "GitHub",
        "tag": "dev"
    },
    {
        "url": "https://stackoverflow.com",
        "title": "Stack Overflow",
        "tag": "dev"
    }
]
```

## Examples

### Basic Workflow
```bash
# Add some bookmarks
python3 lib/bookmark_manager.py add "https://github.com" "GitHub" "dev"
python3 lib/bookmark_manager.py add "https://docs.python.org" "Python Docs" "dev"
python3 lib/bookmark_manager.py add "https://news.ycombinator.com" "Hacker News" "news"

# Browse by tag
python3 lib/bookmark_manager.py list --tag "dev"

# Search across all fields
python3 lib/bookmark_manager.py search "python"

# Get statistics
python3 lib/bookmark_manager.py stats
```

### GUI Integration
```bash
# Set up custom rofi theme
export BOOKMARKSTASH_ROFI_ARGS="-theme Arc-Dark -width 60"

# Add bookmark from clipboard
bookmark-add

# Browse bookmarks visually
bookmark-browse-title
```

### Different Menu Systems
```bash
# Use dmenu instead of rofi
export BOOKMARKSTASH_MENU_SYSTEM="dmenu"
bookmark-browse-tags

# Use fzf for terminal-based browsing
export BOOKMARKSTASH_MENU_SYSTEM="fzf"
bookmark-add
```

## Troubleshooting

### Common Issues

**"Command not found" errors:**
- Run the install script: `./install.sh`
- Ensure scripts are executable: `chmod +x bin/*`
- Add bin/ to PATH or use full paths
- Check that Python 3 is installed: `python3 --version`

**GUI scripts not working:**
- Install required menu system: `sudo apt install rofi` (Ubuntu/Debian)
- Check clipboard manager: `wl-paste` (Wayland) or `xclip` (X11)
- Verify browser installation

**Bookmark manager not found:**
- Set `BOOKMARKSTASH_MANAGER_PATH` to correct location (should be `lib/bookmark_manager.py`)
- Ensure `lib/bookmark_manager.py` has proper permissions

### Debug Mode

Enable detailed logging:
```bash
export BOOKMARKSTASH_DEBUG="1"
bookmark-add  # Will show debug information
```

### Dependency Check

The scripts automatically check for required dependencies and provide helpful error messages. To manually verify:

```bash
# Check what's detected
. lib/bookmarkstash-common.sh
init_bookmarkstash
```

## Contributing

Feel free to submit issues, feature requests, or pull requests. Areas for contribution:
- Additional menu system support
- More browser integrations
- Import/export features
- Additional search capabilities

## License

[Add your license information here]