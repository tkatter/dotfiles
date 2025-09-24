#!/usr/bin/bash
# Sets up my display with `xrandr` for my dual monitor setup
#
# See $HOME/.config/systemd/user/xrandr.service
#   - user systemd daemon that triggers this script
#
# xrandr screen: 3640 x 1920
# 0x0
# +--------+
# |        | 1080x240
# |        +-----------------+
# |  1920  |                 |
# |     x  |   2560 x 1440   |
# |  1080  |                 |
# |        |                 |
# |        +-----------------+
# |        |
# +--------+

# Left monitor (portrait)
xrandr --output DP-2 --mode 1920x1080 --rate 74.97 \
  --rotate left --pos 0x0

# Right monitor (landscape, primary)
xrandr --output DP-4 --mode 2560x1440 --rate 165 --primary \
  --rotate normal --pos 1080x240

# Re-apply wallpaper
~/.fehbg
