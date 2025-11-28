#!/bin/bash
echo "$(date): Attempting to launch omarchy-menu" >> /tmp/omarchy-menu-debug.log
echo "PATH=$PATH" >> /tmp/omarchy-menu-debug.log
echo "DISPLAY=$DISPLAY" >> /tmp/omarchy-menu-debug.log
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" >> /tmp/omarchy-menu-debug.log
/home/grant/.local/share/omarchy/bin/omarchy-menu 2>> /tmp/omarchy-menu-debug.log
echo "Exit code: $?" >> /tmp/omarchy-menu-debug.log