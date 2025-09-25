#!/usr/bin/env sh
#
#
#
input="$(echo "$(wl-paste)" | rofi -dmenu -p "Enter title and tag:")"
title="$(echo "$input" | gawk '{print $1}')"
tag="$(echo "$input" | gawk '{print $2}')"
python "$HOME"/scripts/bookmark_manager.py add "$(wl-paste)" "$title" "$tag"
