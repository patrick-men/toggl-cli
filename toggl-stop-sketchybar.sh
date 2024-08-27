#!/bin/bash

########################################################################
# Plugin that stops the current Toggl entry on Sketchybar click action #
########################################################################

script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/funcs.sh"
source "$script_dir/constants.sh"

current_entry=$(curl -s -v -u $(cat "$credentials_file" | base64 -d) $current_entry_url 2>> ~/.sketchlog)
if ! [[ $current_entry == "null" ]]; then
    end_entry
    ./toggl-view-sketchybar.sh
fi
