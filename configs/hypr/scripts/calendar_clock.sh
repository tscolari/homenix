#!/usr/bin/env bash

# Get current time
current_time="  $(date '+%H:%M:%S')   $(date '+%d, %A')"

# Get calendar events for today and tomorrow
events=$(khal list today tomorrow 2>/dev/null)

# Create tooltip
if [ -z "$events" ]; then
    tooltip="No upcoming events"
else
    tooltip="$events"
fi

# Output JSON - compact, single line
jq -nc \
  --arg text "$current_time" \
  --arg tooltip "$tooltip" \
  '{text: $text, tooltip: $tooltip, class: "calendar"}'
