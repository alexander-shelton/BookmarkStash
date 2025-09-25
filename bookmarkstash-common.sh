#!/usr/bin/env sh
#
# bookmarkstash-common.sh
# Common functions and configuration for BookmarkStash shell scripts
#

# Configuration defaults
DEFAULT_BOOKMARK_MANAGER_PATH="$HOME/scripts/bookmark_manager.py"
DEFAULT_ROFI_THEME=""
DEFAULT_MENU_SYSTEM="rofi"
DEFAULT_FLOATING_TERMINAL="footclient"

# Configuration sources (in order of precedence):
# 1. Environment variables
# 2. Config file
# 3. Defaults

# Load configuration from file if it exists
load_config() {
    local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarkstash/config"
    if [ -f "$config_file" ]; then
        # shellcheck source=/dev/null
        . "$config_file"
    fi
}

# Get bookmark manager path
get_bookmark_manager_path() {
    echo "${BOOKMARKSTASH_MANAGER_PATH:-$DEFAULT_BOOKMARK_MANAGER_PATH}"
}

# Get preferred menu system
get_menu_system() {
    echo "${BOOKMARKSTASH_MENU_SYSTEM:-$DEFAULT_MENU_SYSTEM}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get available clipboard command
get_clipboard_cmd() {
    if [ -n "$BOOKMARKSTASH_CLIPBOARD_CMD" ]; then
        echo "$BOOKMARKSTASH_CLIPBOARD_CMD"
        return
    fi

    # Auto-detect based on environment
    if [ -n "$WAYLAND_DISPLAY" ] && command_exists wl-paste; then
        echo "wl-paste"
    elif [ -n "$DISPLAY" ] && command_exists xclip; then
        echo "xclip -selection clipboard -o"
    elif command_exists pbpaste; then  # macOS
        echo "pbpaste"
    else
        return 1
    fi
}

# Get available browsers in order of preference
get_browser_list() {
    local browsers=""

    # Check for user-specified preferred browser
    if [ -n "$BOOKMARKSTASH_BROWSER" ]; then
        browsers="$BOOKMARKSTASH_BROWSER"
    fi

    # Add common browsers in order of preference
    local common_browsers="firefox google-chrome-stable chromium google-chrome brave-browser opera vivaldi-stable"

    for browser in $common_browsers; do
        if command_exists "$browser"; then
            browsers="$browsers $browser"
        fi
    done

    echo "$browsers" | tr -s ' '
}

# Get the best available browser
get_browser() {
    local browser_list
    browser_list=$(get_browser_list)

    if [ -z "$browser_list" ]; then
        return 1
    fi

    # If user specified a browser, use it if available
    if [ -n "$BOOKMARKSTASH_BROWSER" ] && command_exists "$BOOKMARKSTASH_BROWSER"; then
        echo "$BOOKMARKSTASH_BROWSER"
        return
    fi

    # Check which browsers are currently running (for better user experience)
    for browser in $browser_list; do
        if pidof "$browser" >/dev/null 2>&1; then
            echo "$browser"
            return
        fi
    done

    # If none are running, return the first available
    echo "$browser_list" | awk '{print $1}'
}

# Display menu with the configured menu system
show_menu() {
    local prompt="$1"
    local input="$2"
    local menu_system
    menu_system=$(get_menu_system)

    case "$menu_system" in
        rofi)
            if command_exists rofi; then
                if [ -n "$input" ]; then
                    echo "$input" | rofi -dmenu -i -p "$prompt" ${BOOKMARKSTASH_ROFI_ARGS:-}
                else
                    rofi -dmenu -i -p "$prompt" ${BOOKMARKSTASH_ROFI_ARGS:-}
                fi
            else
                echo "Error: rofi not found" >&2
                return 1
            fi
            ;;
        dmenu)
            if command_exists dmenu; then
                if [ -n "$input" ]; then
                    echo "$input" | dmenu -p "$prompt" ${BOOKMARKSTASH_DMENU_ARGS:-}
                else
                    dmenu -p "$prompt" ${BOOKMARKSTASH_DMENU_ARGS:-}
                fi
            else
                echo "Error: dmenu not found" >&2
                return 1
            fi
            ;;
        fzf)
            if command_exists fzf; then
                if [ -n "$input" ]; then
                    echo "$input" | fzf --prompt="$prompt> " ${BOOKMARKSTASH_FZF_ARGS:-}
                else
                    fzf --prompt="$prompt> " ${BOOKMARKSTASH_FZF_ARGS:-}
                fi
            else
                echo "Error: fzf not found" >&2
                return 1
            fi
            ;;
        *)
            echo "Error: Unknown menu system '$menu_system'" >&2
            return 1
            ;;
    esac
}

# Get available floating terminal
get_floating_terminal() {
    # Check user preference first
    if [ -n "$BOOKMARKSTASH_FLOATING_TERMINAL" ]; then
        if command_exists "$BOOKMARKSTASH_FLOATING_TERMINAL"; then
            echo "$BOOKMARKSTASH_FLOATING_TERMINAL"
            return
        fi
    fi

    # Auto-detect common Sway/Wayland terminals
    local terminals="footclient foot alacritty kitty wezterm gnome-terminal"

    for term in $terminals; do
        if command_exists "$term"; then
            echo "$term"
            return
        fi
    done

    return 1
}

# Get floating terminal arguments for different terminals
get_floating_terminal_args() {
    local terminal="$1"
    local width="${BOOKMARKSTASH_FLOATING_WIDTH:-82}"
    local height="${BOOKMARKSTASH_FLOATING_HEIGHT:-25}"

    case "$terminal" in
        footclient)
            echo "--app-id floating_shell --window-size-chars ${width}x${height}"
            ;;
        foot)
            echo "--app-id floating_shell --window-size-chars ${width}x${height}"
            ;;
        alacritty)
            echo "--class floating_shell --option window.dimensions.columns=$width --option window.dimensions.lines=$height"
            ;;
        kitty)
            echo "--class floating_shell --override initial_window_width=${width}c --override initial_window_height=${height}c"
            ;;
        wezterm)
            echo "--class floating_shell"  # WezTerm uses different config approach
            ;;
        gnome-terminal)
            echo "--class floating_shell --geometry=${width}x${height}"
            ;;
        *)
            echo "--class floating_shell"  # Generic fallback
            ;;
    esac
}

# Launch floating terminal with fzf
launch_floating_fzf() {
    local prompt="$1"

    local terminal
    terminal=$(get_floating_terminal)
    if [ -z "$terminal" ]; then
        echo "Error: No suitable floating terminal found" >&2
        return 1
    fi

    local term_args
    term_args=$(get_floating_terminal_args "$terminal")

    debug_print "Using terminal: $terminal with args: $term_args"

    # Create a temp file to store the input data
    local temp_input="/tmp/bookmarkstash_input_$$"
    local temp_output="/tmp/bookmarkstash_output_$$"

    # Save stdin to temp file
    cat > "$temp_input"

    # Create a simple script that reads from the temp file and runs fzf
    local temp_script="/tmp/bookmarkstash_fzf_$$"
    cat > "$temp_script" << EOF
#!/usr/bin/env sh
selection=\$(cat "$temp_input" | fzf --prompt="$prompt> " \${BOOKMARKSTASH_FZF_ARGS:-} --height=100% --border=rounded --margin=1 --padding=1)
echo "\$selection" > "$temp_output"
EOF
    chmod +x "$temp_script"

    # Launch the terminal and wait for it to complete
    $terminal $term_args -- "$temp_script"

    # Read the result if it exists
    local result=""
    if [ -f "$temp_output" ]; then
        result=$(cat "$temp_output")
    fi

    # Clean up
    rm -f "$temp_script" "$temp_input" "$temp_output"

    echo "$result"
}

# Check if floating mode is enabled
is_floating_mode() {
    [ "${BOOKMARKSTASH_FLOATING:-}" = "1" ] || [ "${BOOKMARKSTASH_FLOATING:-}" = "true" ]
}

# Validate dependencies
check_dependencies() {
    local missing_deps=""
    local menu_system
    menu_system=$(get_menu_system)

    # Check menu system
    if ! command_exists "$menu_system"; then
        missing_deps="$missing_deps $menu_system"
    fi

    # Check clipboard command if needed
    if [ "$1" = "clipboard" ]; then
        if ! get_clipboard_cmd >/dev/null; then
            case "$(uname -s)" in
                Linux)
                    if [ -n "$WAYLAND_DISPLAY" ]; then
                        missing_deps="$missing_deps wl-clipboard"
                    else
                        missing_deps="$missing_deps xclip"
                    fi
                    ;;
                Darwin)
                    # pbpaste is built-in on macOS
                    ;;
                *)
                    missing_deps="$missing_deps clipboard-utility"
                    ;;
            esac
        fi
    fi

    # Check browser if needed
    if [ "$2" = "browser" ]; then
        if ! get_browser >/dev/null; then
            missing_deps="$missing_deps web-browser"
        fi
    fi

    # Check bookmark manager
    local manager_path
    manager_path=$(get_bookmark_manager_path)
    if [ ! -f "$manager_path" ]; then
        echo "Error: Bookmark manager not found at '$manager_path'" >&2
        echo "Set BOOKMARKSTASH_MANAGER_PATH environment variable or update config file" >&2
        return 1
    fi

    if [ -n "$missing_deps" ]; then
        echo "Error: Missing required dependencies:$missing_deps" >&2
        echo "Please install the missing packages or update your configuration" >&2
        return 1
    fi

    return 0
}

# Print debug information if debug mode is enabled
debug_print() {
    if [ "${BOOKMARKSTASH_DEBUG:-}" = "1" ]; then
        echo "DEBUG: $*" >&2
    fi
}

# Show help for environment variables
show_env_help() {
    cat <<EOF
BookmarkStash Configuration Environment Variables:

Required:
  BOOKMARKSTASH_MANAGER_PATH   Path to bookmark_manager.py (default: \$HOME/scripts/bookmark_manager.py)

Optional:
  BOOKMARKSTASH_BROWSER        Preferred browser (auto-detected if not set)
  BOOKMARKSTASH_MENU_SYSTEM    Menu system: rofi, dmenu, fzf (default: rofi)
  BOOKMARKSTASH_CLIPBOARD_CMD  Custom clipboard command (auto-detected if not set)
  BOOKMARKSTASH_ROFI_ARGS      Additional arguments for rofi
  BOOKMARKSTASH_DMENU_ARGS     Additional arguments for dmenu
  BOOKMARKSTASH_FZF_ARGS       Additional arguments for fzf
  BOOKMARKSTASH_DEBUG          Set to '1' to enable debug output

Floating Terminal (Sway-specific):
  BOOKMARKSTASH_FLOATING       Set to '1' or 'true' to enable floating terminal mode
  BOOKMARKSTASH_FLOATING_TERMINAL    Preferred terminal (default: footclient)
  BOOKMARKSTASH_FLOATING_WIDTH       Terminal width in characters (default: 82)
  BOOKMARKSTASH_FLOATING_HEIGHT      Terminal height in characters (default: 25)

Config File:
  \${XDG_CONFIG_HOME:-\$HOME/.config}/bookmarkstash/config

Example config file:
  BOOKMARKSTASH_BROWSER="firefox"
  BOOKMARKSTASH_MENU_SYSTEM="rofi"
  BOOKMARKSTASH_ROFI_ARGS="-theme gruvbox-dark"
EOF
}

# Initialize configuration
init_bookmarkstash() {
    load_config
    debug_print "Bookmark manager: $(get_bookmark_manager_path)"
    debug_print "Menu system: $(get_menu_system)"
    debug_print "Browser: $(get_browser)"
    debug_print "Clipboard: $(get_clipboard_cmd)"
}