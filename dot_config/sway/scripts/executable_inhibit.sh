if [ -f /tmp/inhibit ]; then
    # If the file exists, prevent sleep by exiting with status 1
    exit 1
fi

pactl list sink-inputs | grep "application.name = \"Google Chrome\"" && exit 1 || exit 0
