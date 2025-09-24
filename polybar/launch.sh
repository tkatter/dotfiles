#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log
# echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar main-bar 2>&1 | tee -a /tmp/polybar1.log &
disown
# polybar primary 2>&1 | tee -a /tmp/polybar1.log &
# disown
# polybar secondary 2>&1 | tee -a /tmp/polybar2.log &
# disown

# echo "Bars launched..."

# Terminate already running bar instances
# killall -q polybar
#
# # Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#
# # Launch Polybar on all connected monitors
# # If you have multiple monitors, this will create a bar on each.
# # You can customize which bar goes on which monitor by creating
# # separate bar definitions in config.ini (e.g., bar/main-bar-0, bar/main-bar-1)
# # and then targeting them with POLYBAR_CONFIG=/path/to/config.ini polybar <bar-name>
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#   MONITOR=$m polybar --reload main-bar &
# done
#
# echo "Polybar launched..."
