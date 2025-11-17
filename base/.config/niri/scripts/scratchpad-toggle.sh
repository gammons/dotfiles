#!/bin/bash
# Native niri scratchpad toggle wrapper
# Usage: scratchpad-toggle.sh <app-id> <spawn-command>

APP_ID="$1"
shift
SPAWN_CMD="$@"

# Get window info for the app (includes both visible and scratchpad windows)
WINDOW_INFO=$(niri msg --json windows | jq ".[] | select(.app_id == \"$APP_ID\") | {id, is_focused, is_in_scratchpad}")

if [ -n "$WINDOW_INFO" ]; then
    # Window exists
    WINDOW_ID=$(echo "$WINDOW_INFO" | jq -r '.id')
    IS_IN_SCRATCHPAD=$(echo "$WINDOW_INFO" | jq -r '.is_in_scratchpad')

    if [ "$IS_IN_SCRATCHPAD" = "true" ]; then
        # Window is hidden in scratchpad, show it
        niri msg action scratchpad-show --id "$WINDOW_ID"
    else
        # Window is visible, hide it to scratchpad
        niri msg action move-scratchpad --id "$WINDOW_ID"
    fi
else
    # Window doesn't exist, spawn it
    niri msg action spawn -- $SPAWN_CMD
fi
