#!/bin/bash
# SwiftBar plugin: shows the nuc-tunnel fish function's state, a click toggles it.
# ".10s" in the file name makes SwiftBar rerun it every 10 seconds.
fish=/opt/homebrew/bin/fish
toggle="bash=$fish param1=-c param2=nuc-tunnel terminal=false refresh=true"

if [[ $($fish -c 'nuc-tunnel status') == *": on"* ]]; then
  echo "NUC | sfimage=circle.fill sfcolor=#2F9E4F"
  echo "---"
  echo "Tunnel an | sfimage=circle.fill sfcolor=#2F9E4F"
  echo "localhost:3300 → nucubuntu | size=11"
  echo "---"
  echo "Ausschalten | $toggle"
else
  echo "NUC | sfimage=circle"
  echo "---"
  echo "Tunnel aus | sfimage=circle"
  echo "Port 3300 ist frei | size=11"
  echo "---"
  echo "Einschalten | $toggle"
fi
