#!/usr/bin/env sh
#
# display_bookmarks_by_title.sh
#
if pidof firefox >/dev/null; then
  browser=firefox
else
  browser=google-chrome-stable
fi

python "$HOME"/scripts/bookmark_manager.py titles | rofi -dmenu -i -p "Select a bookmark title" -format 's' | xargs -r python "$HOME"/scripts/bookmark_manager.py search | xargs -I {} $browser "{}" &
