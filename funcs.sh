#!/bin/bash

script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/constants.sh"

# functions to add color to outputs
color_reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)

red_text() {
    echo -e "${red}$1${color_reset}"
}

green_text() {
    echo -e "${green}$1${color_reset}"
}

yellow_text() {
    echo -e "${yellow}$1${color_reset}"
}

blue_text() {
    echo -e "${blue}$1${color_reset}"
}

# help function
function help() {
    echo
    blue_text "toggl - A simple command line tool for Toggl"
    echo
    blue_text "Usage: toggl [options]"
    echo
    yellow_text "Options:"
    yellow_text "   -h, --help       Show this help message and exit"
    yellow_text "   -a, --auth       Prompts for email and password to authenticate"
    yellow_text "   -s, --start      Start a new time entry (starting time: now)"
    yellow_text "   -e, --end        End the current time entry"
    yellow_text "   -l, --list       List time entries"
    yellow_text "   -p, --projects   List all projects"
    yellow_text "   -t, --tags       List all tags"
    yellow_text "   -d, --delete     Delete a time entry"
    echo
    yellow_text "Declarative usage of start and list:"
    yellow_text "   -s --description <description> --tag <tag> --duration <duration>"
    yellow_text "   -l --type <now/interval> --start <start_date> --end <end_date>"
    echo
    echo
    yellow_text "Note: You need to authenticate at least once before using other options."

}

function entry_json_parser() {
    json_description=$(echo $1 | jq -r '.description')
    json_start_time=$(echo $1 | jq -r '.start')
    json_project=$(echo $1 | jq -r '.project')
    json_tags=$(echo $1 | jq -r '.tags')
    
    # start time formatting
    json_start_time=$(echo $1 | jq -r '.start')
    json_start_time=${json_start_time%+00:00}  # remove +00:00
    json_start_time_unix=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$json_start_time" +"%s")
    formatted_start_time=$(date -r $json_start_time_unix "+%d.%m.%y, %H:%M:%S")

    # running time calc
    current_time_unix=$(date +%s)
    running_time_seconds=$((current_time_unix - json_start_time_unix))

    days=$((running_time_seconds/86400))
    hours=$((running_time_seconds/3600%24))
    minutes=$((running_time_seconds/60%60))
    seconds=$((running_time_seconds%60))

    blue_text "Current time entry:"
    echo
    blue_text "Description: $json_description"
    if [[ $json_tags != "[]" ]]; then
        blue_text "Tags: $json_tags"
    fi
    if [[ $json_project != "null" ]]; then
        blue_text "Project: $json_project"
    fi
    blue_text "Start time: $formatted_start_time"
    blue_text "Running time: $days days, $hours hours, $minutes minutes, $seconds seconds"
}

function recent_entries_parser() {
    entry_number=1
    for entry in $(echo $1 | jq -c '.[]'); do
        json_description=$(echo $entry | jq -r '.description')
        json_start_time=$(echo $entry | jq -r '.start')
        json_project=$(echo $entry | jq -r '.project')
        json_tags=$(echo $entry | jq -r '.tags')
        
        # start time formatting
        json_start_time=${json_start_time%+00:00}  # remove +00:00
        json_start_time_unix=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$json_start_time" +"%s")
        formatted_start_time=$(date -r $json_start_time_unix "+%d.%m.%y, %H:%M:%S")

        # running time calc
        current_time_unix=$(date +%s)
        running_time_seconds=$((current_time_unix - json_start_time_unix))

        days=$((running_time_seconds/86400))
        hours=$((running_time_seconds/3600%24))
        minutes=$((running_time_seconds/60%60))
        seconds=$((running_time_seconds%60))

        blue_text "Entry #$entry_number:"

        blue_text "Description: $json_description"
        if [[ $json_tags != "[]" ]]; then
            blue_text "Tags: $json_tags"
        fi
        if [[ $json_project != "null" ]]; then
            blue_text "Project: $json_project"
        fi
        blue_text "Start time: $formatted_start_time"
        blue_text "Running time: $days days, $hours hours, $minutes minutes, $seconds seconds"
        echo

        entry_number=$((entry_number+1))  
    done
}


function now_entry_lookup() {
    current_entry=$(curl -s -u $(cat $credentials_file | base64 -d) $current_entry_url)

    if [[ $current_entry == "null" ]]; then
        yellow_text "No current time entry."
        return 1
    else
        entry_json_parser $current_entry
    fi
}

function interval_entry_lookup() {
    
    if [[ "$#" -eq 2 ]]; then
        start_date=$1
        end_date=$2
    else    
        read -p "Enter the start time in the following format > DD.MM.YY: " start_date
        echo
        read -p "Enter the end time in the following format > DD.MM.YY: " end_date
        echo
    fi

    yellow_text "Start date: $start_date"
    yellow_text "End date: $end_date"
    echo
    
    if [[ -z $start_date ]] || [[ -z $end_date ]]; then
        red_text "Invalid time range. Please try again."
        return 1
    fi

    # Convert start_time and end_time to the format "YYYY-MM-DDTHH:MM:SSZ"
    start_time=$(date -j -f "%d.%m.%y" "$start_date" +"%Y-%m-%d")
    end_time=$(date -j -f "%d.%m.%y" "$end_date" +"%Y-%m-%d")

    queried_entries=$(curl -s -u $(cat $credentials_file | base64 -d) "$time_entries_url?start_date=$start_time&end_date=$end_time")

    if [[ $queried_entries == "[]" ]]; then
        yellow_text "No entries found within the given time range."
        return 1
    else
        recent_entries_parser $queried_entries
    fi
}

function list_entries() {    
    if [[ "$#" -eq 0 ]]; then
        yellow_text "Do you wish to see the current time entry (1) or the entries within a given time range (2)?"
        echo
        read -p "Enter your choice: " choice
        echo

        if [[ $choice == "1" ]]; then
            now_entry_lookup

        elif [[ $choice == "2" ]]; then
            read -p "Enter the start time in the following format > DD.MM.YY: " start_date
            echo
            read -p "Enter the end time in the following format > DD.MM.YY: " end_date
            echo
            
            interval_entry_lookup "$start_date" "$end_date"

        else
            red_text "Invalid choice. Please try again."
            list_entries
        fi
    elif [[ "$#" -eq 3 ]]; then
        for arg in "$@"; do
            key=$(echo $arg | cut -d':' -f1)
            value=$(echo $arg | cut -d':' -f2)
                
            case "$key" in
                type)
                    type=$value
                    ;;
                start)
                    start_date=$value
                    ;;
                end)
                    end_date=$value
                    ;;
                *)
                    echo "Error: Unsupported flag $key" >&2
                    exit 1
                    ;;
            esac
        done

        if [[ -z $type ]]; then
            echo "Error: type not set" >&2
            exit 1
        elif [[ $type == "now" ]]; then
            now_entry_lookup
        elif [[ $type == "interval" ]]; then
            interval_entry_lookup $start_date $end_date
        else
            echo "Error: Unsupported flag $type" >&2
            exit 1
        fi 
    else
        echo "Error: Unsupported amount of flags" >&2
        exit 1
    fi
}

function list_projects() {
    workspace_id=$(get_workspace_id)
    projects_url="https://api.track.toggl.com/api/v9/workspaces/$workspace_id/projects"
    available_projects=$(curl -s -u $(cat $credentials_file | base64 -d) $projects_url)
    
    if [[ $available_projects == "[]" ]]; then
        available_projects="No projects available"
        yellow_text "$available_projects"
        return 1
    fi
    yellow_text "$available_projects"
}

function list_tags() {
    available_tags=$(curl -s -u $(cat $credentials_file | base64 -d) $tags_url)
    
    if [[ $available_tags == "[]" ]]; then
        available_tags="No tags available"
        yellow_text "$available_tags"
        return 1
    fi
    yellow_text "$available_tags"
}

function start_entry() {

    workspace_id=$(get_workspace_id)

    if [[ "$#" -eq 0 ]]; then
        yellow_text "Starting a new time entry..."
        echo

        read -p "Enter the description: " entry_description
        
        if list_tags > /dev/null; then
            read -p "Enter the tags ($available_tags): " entry_tags
        fi 

        if list_projects > /dev/null; then
            read -p "Enter the project: " entry_project
        fi
        
        read -p "Enter the start time (default: now): " entry_start_time
        
        read -p "Enter the duration (default: until stopped): " entry_duration
        
        read -p "Enter the stop time (default: when stopped): " entry_stop_time

    else
        while (( "$#" )); do
            key=$(echo $1 | cut -d':' -f1)
            value=$(echo $1 | cut -d':' -f2)

            case "$key" in
                description)
                    entry_description=$value
                    ;;
                tags)
                    entry_tags=$value
                    ;;
                duration)
                    entry_duration=$value
                    ;;
                --) # end argument parsing
                    break
                    ;;
                *)
                    echo "Error: Unsupported flag $key" >&2
                    exit 1
                    ;;
            esac
            shift
        done
    fi

    # prep default values

    if [[ -z $entry_start_time ]]; then
        entry_start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    fi

    if [[ -z $entry_duration ]]; then
        entry_duration="-1"
    fi

    if [[ -z $entry_stop_time ]]; then
        entry_stop_time="null"
    fi  

    curl -s -X POST https://api.track.toggl.com/api/v9/workspaces/$workspace_id/time_entries \
        -u $(cat $credentials_file | base64 -d) \
        -H "Content-Type: application/json" \
        -d '{
            "description": "'"$entry_description"'",
            "tags": ["'"$entry_tags"'"],
            "workspace_id": '"$workspace_id"',
            "duration": '"$entry_duration"',
            "start": "'"$entry_start_time"'",
            "created_with": "toggl-cli"
        }' > /dev/null
}

function end_entry() {
    current_entry=$(curl -s -u $(cat $credentials_file | base64 -d) $current_entry_url)
    workspace_id=$(get_workspace_id)

    if [[ $current_entry == "null" ]]; then
        yellow_text "No current time entry."
        return 1
    else
        entry_id=$(echo $current_entry | jq -r '.id')
        end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        curl -s -X PATCH https://api.track.toggl.com/api/v9/workspaces/$workspace_id/time_entries/$entry_id/stop \
            -u $(cat $credentials_file | base64 -d) > /dev/null
        
        green_text "Time entry ended."
    fi
}


### AUTHENTICATION ###

function read_password() {
    unset password
    prompt="Enter Password: "
    while IFS= read -p "$prompt" -r -s -n 1 char
    do
        if [[ $char == $'\0' ]]; then
            break
        fi
        if [[ $char == $'\177' ]]; then
            password="${password%?}"
            prompt=$'\b \b'
        else
            prompt='*'
            password+="$char"
        fi
    done
    echo
}

function credentials_file_check() {
    if ! [ -f "$credentials_file" ]; then
        mkdir -p "$(dirname "$credentials_file")"
        touch "$credentials_file"
    else    
        yellow_text "Credentials have already been set up."
        exit 0
    fi
}

function get_workspace_id() {
    cat $workspace_id_file
}

# get credentials and check if they're correct
function auth() {
    credentials_file_check

    yellow_text "This is the first time you're using this tool. Let's authenticate you."
    
    read -p "Enter your email: " email
    read_password

    echo -e "$email:$password" | base64 > $credentials_file

    result=$(curl -u $(cat $credentials_file | base64 -d) $auth_url)

    if [[ "$result" =~ "Incorrect.*" ]]; then
        red_text "It looks like you've made a mistake. Let's try again."
        auth
    else
        default_workspace_id=$(echo $result | jq -r '.default_workspace_id')
        echo $default_workspace_id > $workspace_id_file

        blue_text "Successfully authenticated."
        exit 0
    fi
}