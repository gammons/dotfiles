#!/usr/bin/env bash

LOCK_CMD="~/.config/sway/scripts/lock.sh"
SLEEP_CMD="~/.config/sway/scripts/sleep.sh"
RESUME_CMD="~/.config/sway/scripts/resume.sh"

LOCK_TIMEOUT=300
SLEEP_TIMEOUT=600

swayidle timeout $LOCK_TIMEOUT $LOCK_CMD \
  timeout $SLEEP_TIMEOUT $SLEEP_CMD \
  before-sleep $LOCK_CMD\
  after-resume $RESUME_CMD

