#!/bin/bash

HEADSET_CARD_NAME="alsa_card.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00"
DESIRED_CARD_PROFILE="output:iec958-stereo+input:mono-fallback"
DESIRED_SINK_PORT="iec958-stereo-output"
HEADSET_SINK_NAME="alsa_output.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00.iec958-stereo"

# DESIRED_CARD_PROFILE="output:iec958-stereo+input:mono-fallback"
# DESIRED_SINK_PORT="iec958-stereo-output"
# HEADSET_CARD_INDEX="646"
# HEADSET_CARD_NAME="alsa_card.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00"
# HEADSET_SINK_NAME="alsa_output.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00.iec958-stereo.4"
# HEADSET_SOURCE_NAME="alsa_output.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00.iec958-stereo.4.monitor"

log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [razer-monitor] $@" >&2
  logger -t razer-monitor "$@"
}

wait_for_pulseaudio() {
  local count=0
  while ! pactl info >/dev/null 2>&1; do
    if [ $count -ge 30 ]; then
      log_message "Error: PulseAudio not available after 30 seconds"
      return 1
    fi
    sleep 1
    count=$((count + 1))
  done
  log_message "PulseAudio is ready"
  return 0
}

setup_headset() {
  local card_index="$1"

  log_message "Setting up Razer headset (card $card_index)"

  # Set profile
  log_message "Setting card profile to: $DESIRED_CARD_PROFILE"
  pactl set-card-profile "$card_index" "$DESIRED_CARD_PROFILE"

  sleep 2

  # Find and configure sink
  local current_sink_name=$(pactl list sinks short | grep -F "$HEADSET_SINK_NAME" | awk '{print $2}')
  if [ -n "$current_sink_name" ]; then
    log_message "Setting default sink: $current_sink_name"
    pactl set-default-sink "$current_sink_name"

    log_message "Setting volume to 100%"
    pactl set-sink-volume "$current_sink_name" 65536

    log_message "Setting port: $DESIRED_SINK_PORT"
    pactl set-sink-port "$current_sink_name" "$DESIRED_SINK_PORT"

    log_message "Setup complete for $current_sink_name"
  else
    log_message "Warning: Sink not found: $HEADSET_SINK_NAME"
  fi
}

log_message "Razer headset monitor started"

# Wait for PulseAudio to be ready
if ! wait_for_pulseaudio; then
  exit 1
fi

# Track if we've seen the card before
CARD_SEEN=""

while true; do
  # Check if card exists
  CURRENT_CARD=$(pactl list cards short 2>/dev/null | grep "$HEADSET_CARD_NAME" | awk '{print $1}')

  if [ -n "$CURRENT_CARD" ] && [ "$CARD_SEEN" != "$CURRENT_CARD" ]; then
    log_message "New Razer headset detected (card $CURRENT_CARD)"
    CARD_SEEN="$CURRENT_CARD"

    # Setup headset directly in this script
    setup_headset "$CURRENT_CARD"

  elif [ -z "$CURRENT_CARD" ] && [ -n "$CARD_SEEN" ]; then
    # Card disappeared
    log_message "Razer headset disconnected"
    CARD_SEEN=""
  fi

  sleep 3
done
# #!/bin/bash
#
# HEADSET_CARD_NAME="alsa_card.usb-1532_Razer_BlackShark_V2_Pro_2.4_O001000007-00"
# SETUP_SCRIPT="/home/thomas/.config/razer-audio-setup.sh"
#
# log_message() {
#   echo "$(date +'%Y-%m-%d %H:%M:%S') [razer-monitor] $@" >&2
#   logger -t razer-monitor "$@"
# }
#
# log_message "Razer headset monitor started"
#
# # Track if we've seen the card before
# CARD_SEEN=""
#
# while true; do
#   # Check if card exists
#   CURRENT_CARD=$(pactl list cards short 2>/dev/null | grep "$HEADSET_CARD_NAME" | awk '{print $1}')
#
#   if [ -n "$CURRENT_CARD" ] && [ "$CARD_SEEN" != "$CURRENT_CARD" ]; then
#     log_message "New Razer headset detected (card $CURRENT_CARD), running setup..."
#     CARD_SEEN="$CURRENT_CARD"
#
#     # Run setup script
#     bash "$SETUP_SCRIPT" &
#
#   elif [ -z "$CURRENT_CARD" ]; then
#     # Card disappeared, reset tracking
#     CARD_SEEN=""
#   fi
#
#   sleep 2
# done
