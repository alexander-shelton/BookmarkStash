#!/usr/bin/env sh
#
# display_bookmarks_by_tags.sh
#
if pidof firefox >/dev/null; then
  browser=firefox
else
  browser=google-chrome-stable
fi

tags=$(python "$HOME"/scripts/bookmark_manager.py tags | rofi -dmenu -i -p "select a bookmark tag" -format 's' | xargs -r python "$HOME"/scripts/bookmark_manager.py search --tag)
echo "$tags" | rofi -dmenu -i -p "Select a bookmark" -format 's' | xargs -r python "$HOME"/scripts/bookmark_manager.py search | xargs -I {} firefox "{}" &
