#!/bin/bash

#TODO: handle case where no task is ongoing
#TODO: split into 3 > one with current task that stops task on click, one that starts task type X and one that starts task type Y
script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/funcs.sh"
source "$script_dir/constants.sh"

NAME="toggl"

current_entry=$(curl -s -v -u $(cat "$credentials_file" | base64 -d) $current_entry_url 2>> ~/.sketchlog)
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

json_start_time=$(echo $current_entry | jq -r '.start')
        

# start time formatting
json_start_time=${json_start_time%+00:00}  # remove +00:00
json_start_time_unix=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$json_start_time" +"%s")

current_time_unix=$(date +%s)
running_time_seconds=$((current_time_unix - json_start_time_unix))


if (( running_time_seconds < 60 )); then
    TIME_RUNNING="0d 0h 0m"
else
    days=$((running_time_seconds/86400))
    hours=$((running_time_seconds/3600%24))
    minutes=$((running_time_seconds/60%60))

    TIME_RUNNING="${days}d ${hours}h ${minutes}m"
fi

output="$(printf "%s - %s" "$DESCRIPTION" "$TIME_RUNNING" | xargs)"

sketchybar -m --set $NAME label="$output"
