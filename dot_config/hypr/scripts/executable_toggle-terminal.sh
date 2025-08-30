#!/bin/bash

# Get the special workspace ID for the floating terminal
SPECIAL_WORKSPACE="special:terminal"
TERMINAL_CLASS="floating-terminal"

# Check if a terminal with our class already exists
if hyprctl clients -j | jq -e ".[] | select(.class == \"$TERMINAL_CLASS\")" > /dev/null 2>&1; then
    # Terminal exists, toggle the special workspace and recenter
    hyprctl dispatch togglespecialworkspace terminal
    
    # If showing the terminal, recenter it for current monitor
    if hyprctl clients -j | jq -e ".[] | select(.class == \"$TERMINAL_CLASS\" and .workspace.name == \"$SPECIAL_WORKSPACE\")" > /dev/null 2>&1; then
        hyprctl dispatch centerwindow
    fi
else
    # Terminal doesn't exist, create it
    alacritty --class "$TERMINAL_CLASS" &
    sleep 0.3
    
    # Get current monitor dimensions
    MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
    MONITOR_WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
    MONITOR_HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
    
    # Calculate terminal size - square at 30% of the smaller dimension
    if [ "$MONITOR_WIDTH" -lt "$MONITOR_HEIGHT" ]; then
        TERM_SIZE=$((MONITOR_WIDTH * 30 / 100))
    else
        TERM_SIZE=$((MONITOR_HEIGHT * 30 / 100))
    fi
    TERM_WIDTH=$TERM_SIZE
    TERM_HEIGHT=$TERM_SIZE
    
    # Move it to special workspace and configure with exact pixel sizes
    hyprctl --batch "dispatch movetoworkspacesilent $SPECIAL_WORKSPACE,class:$TERMINAL_CLASS ; \
                     dispatch togglespecialworkspace terminal ; \
                     dispatch resizeactive exact ${TERM_WIDTH} ${TERM_HEIGHT} ; \
                     dispatch centerwindow"
fi