#!/bin/bash

# Get the special workspace ID for floating Obsidian
SPECIAL_WORKSPACE="special:obsidian"
OBSIDIAN_CLASS="obsidian"

# Check if Obsidian already exists
if hyprctl clients -j | jq -e ".[] | select(.class == \"$OBSIDIAN_CLASS\")" > /dev/null 2>&1; then
    # Obsidian exists, toggle the special workspace
    hyprctl dispatch togglespecialworkspace obsidian
    
    # If showing Obsidian, position it on right half
    if hyprctl monitors -j | jq -e '.[] | select(.specialWorkspace.name == "special:obsidian")' > /dev/null 2>&1; then
        # Get current monitor dimensions
        MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
        MONITOR_WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
        MONITOR_HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
        
        # Calculate size (50% width, 95% height)
        OBS_WIDTH=$((MONITOR_WIDTH / 2))
        OBS_HEIGHT=$((MONITOR_HEIGHT * 95 / 100))
        
        # Position on right half
        OBS_X=$((MONITOR_WIDTH / 2))
        OBS_Y=$((MONITOR_HEIGHT * 25 / 1000))  # 2.5% from top
        
        hyprctl --batch "dispatch resizeactive exact ${OBS_WIDTH} ${OBS_HEIGHT} ; \
                         dispatch moveactive exact ${OBS_X} ${OBS_Y}"
    fi
else
    # Obsidian doesn't exist, create it
    uwsm app -- obsidian -disable-gpu &
    
    # Wait for window to appear
    for i in {1..10}; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$OBSIDIAN_CLASS\")" > /dev/null 2>&1; then
            break
        fi
        sleep 0.2
    done
    
    # Get Obsidian window address
    OBSIDIAN_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$OBSIDIAN_CLASS\") | .address" | head -1)
    
    # Get current monitor dimensions - get the monitor where Obsidian appeared
    OBSIDIAN_MON=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$OBSIDIAN_CLASS\") | .monitor" | head -1)
    MONITOR_INFO=$(hyprctl monitors -j | jq ".[] | select(.id == $OBSIDIAN_MON)")
    MONITOR_WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
    MONITOR_HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
    
    # Debug output
    echo "=== Obsidian Debug ==="
    echo "Monitor: ${OBSIDIAN_MON}"
    echo "Width: ${MONITOR_WIDTH}"
    echo "Height: ${MONITOR_HEIGHT}"
    echo "Addr: ${OBSIDIAN_ADDR}"
    
    # Calculate size (50% width, 95% height)
    OBS_WIDTH=$((MONITOR_WIDTH / 2))
    OBS_HEIGHT=$((MONITOR_HEIGHT * 95 / 100))
    
    # Position on right half
    OBS_X=$((MONITOR_WIDTH / 2))
    OBS_Y=$((MONITOR_HEIGHT * 25 / 1000))  # 2.5% from top
    
    # Debug output
    echo "=== Calculated Position ==="
    echo "Size: ${OBS_WIDTH}x${OBS_HEIGHT}"
    echo "Pos: ${OBS_X},${OBS_Y}"
    
    # Move ONLY Obsidian to special workspace using its address
    echo "=== Executing commands ==="
    echo "hyprctl --batch \"dispatch movetoworkspacesilent $SPECIAL_WORKSPACE,address:$OBSIDIAN_ADDR ; dispatch togglespecialworkspace obsidian ; dispatch resizeactive exact ${OBS_WIDTH} ${OBS_HEIGHT} ; dispatch moveactive exact ${OBS_X} ${OBS_Y}\""
    
    hyprctl --batch "dispatch movetoworkspacesilent $SPECIAL_WORKSPACE,address:$OBSIDIAN_ADDR ; \
                     dispatch togglespecialworkspace obsidian ; \
                     dispatch resizeactive exact ${OBS_WIDTH} ${OBS_HEIGHT} ; \
                     dispatch moveactive exact ${OBS_X} ${OBS_Y}"
    
    # Check final position after a delay
    sleep 1
    FINAL_POS=$(hyprctl clients -j | jq ".[] | select(.class == \"$OBSIDIAN_CLASS\") | {at: .at, size: .size}")
    echo "=== Final Position (after 1s) ==="
    echo "$FINAL_POS"
fi