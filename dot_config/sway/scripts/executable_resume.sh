#!/usr/bin/env bash

LID="`ls /proc/acpi/button/lid | head -n1`"

if grep -q open /proc/acpi/button/lid/${LID}/state; then
  ~/.config/sway/scripts/lid_up
else
  ~/.config/sway/scripts/lid_down
fi
