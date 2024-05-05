if [ -f /tmp/inihibit ]; then
    # If the file exists, prevent sleep by exiting with status 1
    exit 1
fi

pactl list | grep RUNNING && exit 1 || exit 0
