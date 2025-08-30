#!/bin/bash

# Simple toggle for Obsidian using scratchpad-like behavior
OBSIDIAN_CLASS="obsidian"

# Check if Obsidian exists
if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$OBSIDIAN_CLASS\")" > /dev/null 2>&1; then
    # Launch Obsidian if not running
    uwsm app -- obsidian -disable-gpu &
    sleep 2
    
    # Move to scratchpad
    hyprctl dispatch movetoworkspacesilent special:obsidian,class:$OBSIDIAN_CLASS
fi

# Toggle the scratchpad
hyprctl dispatch togglespecialworkspace obsidian