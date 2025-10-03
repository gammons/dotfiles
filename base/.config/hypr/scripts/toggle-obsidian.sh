#!/bin/bash

# Simple Obsidian toggle - matching sway config approach
OBSIDIAN_CLASS="obsidian"
SPECIAL_WORKSPACE="special:obsidian"

# Launch if doesn't exist
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$OBSIDIAN_CLASS\")" >/dev/null 2>&1; then
  uwsm app -- obsidian &
  sleep 0.5
  hyprctl dispatch movetoworkspacesilent $SPECIAL_WORKSPACE,class:$OBSIDIAN_CLASS
fi

# Check if workspace is visible before toggling
VISIBLE=$(hyprctl monitors -j | jq -e '.[] | select(.specialWorkspace.name == "special:obsidian")' >/dev/null 2>&1 && echo "yes" || echo "no")

# Toggle the workspace
hyprctl dispatch togglespecialworkspace obsidian

# If we just showed it, resize and position using percentages (like sway)
if [ "$VISIBLE" = "no" ]; then
  sleep 0.1
  hyprctl dispatch resizeactive exact 48% 90%
  hyprctl dispatch moveactive exact 51% 5%
fi
