
#!/usr/bin/env bash

swww-daemon &

while true; do

  f="`echo $HOME`/.config/hypr/images/`ls ~/.config/hypr/images | shuf -n 1`"
  echo $f
  swww img $f
  sleep 600
done
