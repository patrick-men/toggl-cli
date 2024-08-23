#!/bin/bash

source funcs.sh
source constants.sh

NAME="toggl"

current_entry=$(curl -s -u $(cat $credentials_file | base64 -d) $current_entry_url)

if [[ $current_entry == "null" ]]; then
    red_text "No current time entry found."
    exit 1
fi

DESCRIPTION=$(echo $current_entry | jq -r '.description')

# Check if TASK is empty
if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="No task"
fi

# running time calc
json_running_time=$(echo $current_entry | jq -r '.duration')
current_time_unix=$(date +%s)

running_time_seconds=$((current_time_unix + json_running_time))

days=$((running_time_seconds/86400))
hours=$((running_time_seconds/3600%24))
minutes=$((running_time_seconds/60%60))

TIME_RUNNING="${days}d ${hours}h ${minutes}m"

output="$(printf "%s - %s" "$DESCRIPTION" "$TIME_RUNNING" | xargs)"

echo $output

sketchybar -m --set $NAME label="$output"