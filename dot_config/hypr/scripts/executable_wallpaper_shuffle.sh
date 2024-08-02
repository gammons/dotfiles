
#!/usr/bin/env bash

while true; do

  f="`echo $HOME`/.config/hypr/images/wallpapers/`ls ~/.config/hypr/images/wallpapers | shuf -n 1`"
  echo $f
  swww img $f
  sleep 600
done
