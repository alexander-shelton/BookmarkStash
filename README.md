# BookmarkStash

A simple, powerful bookmark manager that bridges the gap between command-line efficiency and GUI convenience. Built around shell scripts with seamless integration for rofi, dmenu, and fzf.

## ✨ Features

- **One-click bookmark adding** from clipboard with GUI prompts
- **Visual bookmark browsing** by title or tag using your favorite menu system
- **Cross-platform clipboard support** (Wayland, X11, macOS)
- **Smart browser detection** and launching
- **Clean command-line interface** for power users
- **Flexible configuration** with environment variables and config files
- **JSON storage** with human-readable format

## 🚀 Quick Start

```bash
# Install
git clone https://github.com/yourusername/BookmarkStash.git
cd BookmarkStash
./install.sh

# Add a bookmark from clipboard (GUI)
bookmark-add

# Browse your bookmarks (GUI)
bookmark-browse-title
bookmark-browse-tags

# Direct CLI usage
bookmark-manager add "https://github.com" "GitHub" "dev"
bookmark-manager list --tag "dev"
```

## 📦 Installation

### Automated Installation (Recommended)

```bash
git clone https://github.com/yourusername/BookmarkStash.git
cd BookmarkStash
./install.sh
```

The install script will:

- ✅ Make all scripts executable
- ✅ Create a `bookmark-manager` command for CLI access
- ✅ Offer to add commands to your shell's PATH
- ✅ Set up configuration directory with example config
- ✅ Test the installation

### Manual Installation

```bash
# Make scripts executable
chmod +x bin/*

# Add to PATH (add to ~/.bashrc, ~/.zshrc, etc.)
export PATH="$PWD/bin:$PATH"

# Create config
mkdir -p ~/.config/bookmarkstash
cp config/config.example ~/.config/bookmarkstash/config
```

### Prerequisites

**Required:**

- Python 3.6+

**Optional (for GUI features):**

- Menu system: `rofi` (recommended), `dmenu`, or `fzf`
- Clipboard: `wl-paste` (Wayland), `xclip` (X11), or `pbpaste` (macOS)
- Web browser: Any modern browser (auto-detected)

## 🎯 Usage

### GUI Commands (Main Interface)

```bash
# Add bookmark from clipboard with GUI prompt
bookmark-add

# Browse all bookmarks by title
bookmark-browse-title

# Browse bookmarks by tag, then select specific bookmark
bookmark-browse-tags
```

### CLI Commands (Power User)

```bash
# Add bookmarks
bookmark-manager add "https://example.com" "Example Site" "web"
bookmark-manager add "example.com" "Example" "web"  # Auto-adds https://

# List bookmarks
bookmark-manager list                    # All bookmarks
bookmark-manager list --tag "dev"       # By tag
bookmark-manager list --title "GitHub"  # By title

# Search bookmarks
bookmark-manager search "python"        # Search all fields
bookmark-manager search --tag "dev"     # Search by tag
bookmark-manager search --title "docs"  # Search by title

# Manage bookmarks
bookmark-manager delete --url "https://example.com"
bookmark-manager delete --title "Example Site"
bookmark-manager tags                    # List all tags
bookmark-manager titles                  # List all titles
bookmark-manager stats                   # Show statistics

# Custom data file
bookmark-manager --file /path/to/custom.json list
```

## ⚙️ Configuration

### Environment Variables

Set in your shell config (`~/.bashrc`, `~/.zshrc`) or in the config file:

```bash
# Paths (usually auto-detected)
BOOKMARKSTASH_MANAGER_PATH="/path/to/lib/bookmark_manager.py"

# Customization
BOOKMARKSTASH_BROWSER="firefox"                    # Preferred browser
BOOKMARKSTASH_MENU_SYSTEM="rofi"                   # Menu: rofi, dmenu, fzf
BOOKMARKSTASH_DEBUG="1"                            # Enable debug output

# Menu styling
BOOKMARKSTASH_ROFI_ARGS="-theme gruvbox-dark -width 50"
BOOKMARKSTASH_DMENU_ARGS="-fn 'DejaVu Sans Mono-12'"
BOOKMARKSTASH_FZF_ARGS="--height=40% --layout=reverse"
```

### Config File

Create `~/.config/bookmarkstash/config`:

```bash
# Uses same variable names as environment variables
BOOKMARKSTASH_BROWSER="brave"
BOOKMARKSTASH_MENU_SYSTEM="rofi"
BOOKMARKSTASH_ROFI_ARGS="-theme Arc-Dark -width 60"
```

Priority order: Environment Variables → Config File → Defaults

### View All Options

```bash
# See all configuration options and current values
. lib/bookmarkstash-common.sh && show_env_help
```

## 📁 Project Structure

```
BookmarkStash/
├── install.sh              # One-command installation
├── bin/                     # Main user commands
│   ├── bookmark-add         # Add from clipboard (GUI)
│   ├── bookmark-browse-title # Browse by title (GUI)
│   ├── bookmark-browse-tags # Browse by tag (GUI)
│   └── bookmark-manager     # Direct CLI access
├── lib/                     # Backend components
│   ├── bookmark_manager.py  # Core Python engine
│   ├── bookmarkstash-common.sh # Shell functions
│   └── platform-specific/
│       └── sway-specific.sh # Platform adaptations
└── config/
    └── config.example       # Configuration template
```

## 🌐 Platform Support

### Menu Systems

- **rofi** - Feature-rich launcher (recommended)
- **dmenu** - Minimalist dynamic menu
- **fzf** - Terminal-based fuzzy finder

### Clipboard Managers

- **wl-paste** - Wayland (auto-detected)
- **xclip** - X11 (auto-detected)
- **pbpaste** - macOS (auto-detected)

### Browsers

Auto-detects and prioritizes running browsers:
Firefox, Chrome/Chromium, Brave, Opera, Vivaldi, Safari

## 💾 Data Storage

- **Location:** `~/.bookmarks.json` (default, configurable)
- **Format:** JSON array with UTF-8 encoding
- **Structure:** Objects with `url`, `title`, `tag` fields

Example:

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

## 🔧 Troubleshooting

### Common Issues

**Command not found:**

```bash
# Run the installer
./install.sh

# Or manually add to PATH
export PATH="$PWD/bin:$PATH"
```

**GUI not working:**

```bash
# Install menu system
sudo apt install rofi          # Ubuntu/Debian
brew install rofi              # macOS
sudo pacman -S rofi            # Arch

# Install clipboard manager
sudo apt install wl-clipboard  # Wayland
sudo apt install xclip         # X11
```

**Python script not found:**

```bash
# Check the path
ls lib/bookmark_manager.py

# Or set manually
export BOOKMARKSTASH_MANAGER_PATH="$PWD/lib/bookmark_manager.py"
```

### Debug Mode

Enable detailed logging:

```bash
export BOOKMARKSTASH_DEBUG="1"
bookmark-add  # Will show debug info
```

### Verify Installation

```bash
# Check what's detected
. lib/bookmarkstash-common.sh
init_bookmarkstash
```

## 🎨 Examples

### Basic Workflow

```bash
# Add some bookmarks
bookmark-manager add "https://github.com" "GitHub" "dev"
bookmark-manager add "https://docs.python.org" "Python Docs" "dev"
bookmark-manager add "https://news.ycombinator.com" "Hacker News" "news"

# Browse visually
bookmark-browse-tags  # Select 'dev' → Select 'GitHub' → Opens in browser

# CLI power user
bookmark-manager search "python"
bookmark-manager list --tag "dev"
bookmark-manager stats
```

### Customization

```bash
# Custom rofi theme
export BOOKMARKSTASH_ROFI_ARGS="-theme Arc-Dark -width 70"
bookmark-browse-title

# Use different menu system
export BOOKMARKSTASH_MENU_SYSTEM="fzf"
bookmark-add

# Custom browser
export BOOKMARKSTASH_BROWSER="brave"
```

## 🤝 Contributing

Issues, feature requests, and pull requests are welcome! Areas for contribution:

- Additional menu system support
- Browser integration improvements
- Import/export features (browser bookmarks, etc.)
- Additional search capabilities
- Platform-specific optimizations

## 📝 License

[MIT License](LICENSE)

---

**Made for people who love both keyboard shortcuts and visual interfaces.** 🚀

