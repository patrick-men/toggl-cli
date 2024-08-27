#!/bin/bash

###############################################################
# Plugin that shows the current Toggl entry in the Sketchybar #
###############################################################

script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/funcs.sh"
source "$script_dir/constants.sh"

name="toggl-view"

current_entry=$(curl -s -v -u $(cat "$credentials_file" | base64 -d) $current_entry_url 2>> ~/.sketchlog)
if [[ $current_entry == "null" ]]; then
    output="No entry"
    sketchybar -m --set $name label="$output"
    exit 0
fi

description=$(echo $current_entry | jq -r '.description')

# running time calc

json_start_time=$(echo $current_entry | jq -r '.start')
        

# start time formatting
json_start_time=${json_start_time%+00:00}  # remove +00:00
json_start_time_unix=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$json_start_time" +"%s")

current_time_unix=$(date +%s)
running_time_seconds=$((current_time_unix - json_start_time_unix))


if (( running_time_seconds < 60 )); then
    time_running="0d 0h 0m"
else
    days=$((running_time_seconds/86400))
    hours=$((running_time_seconds/3600%24))
    minutes=$((running_time_seconds/60%60))

    time_running="${days}d ${hours}h ${minutes}m"
fi

output="$(printf "%s - %s" "$description" "$time_running" | xargs)"

sketchybar -m --set $name label="$output"