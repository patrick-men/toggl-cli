#!/bin/bash

###################################################################
# Plugin that allow start and stop of certarin task in Sketchybar #
###################################################################

script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/funcs.sh"
source "$script_dir/constants.sh"

## Add your custom values here ##
description="task1"
tags="tag1"
duration="-1" # default value for "until stopped"

# check if the flag file exists > this makes sure that the script doens't run on the very first go
flag_file="/tmp/toggl_task1_sketchybar_flag"

# stop script if there is an entry running
current_entry=$(curl -s -v -u $(cat "$credentials_file" | base64 -d) $current_entry_url 2>> ~/.sketchlog)
if ! [[ $current_entry == "null" ]]; then
    exit 0
fi

if [[ -f "$flag_file" ]]; then
    entry_start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    workspace_id=$(get_workspace_id)

    curl -s -X POST https://api.track.toggl.com/api/v9/workspaces/$workspace_id/time_entries \
            -u $(cat $credentials_file | base64 -d) \
            -H "Content-Type: application/json" \
            -d '{
                "description": "'"$description"'",
                "tags": ["'"$tags"'"],
                "workspace_id": '"$workspace_id"',
                "duration": '"$duration"',
                "start": "'"$entry_start_time"'",
                "created_with": "toggl-cli"
            }' > /dev/null

    ./toggl-view-sketchybar.sh
else
    touch "$flag_file"
fi

