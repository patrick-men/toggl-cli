#!/bin/bash

#TODO: Fix declarative use of list_entries
script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/funcs.sh"

# echo to create an empty line at the beginning of the output
echo

while (( "$#" )); do
    case "$1" in
        -h|--help)
            help
            shift
            ;;
        -a|--auth)
            auth
            shift
            ;;
        -s|--start)
            shift
            start_params=()
            while (( "$#" )); do
                case "$1" in
                    --description)
                        start_params+=("description:$2")
                        shift
                        ;;
                    --tag)
                        start_params+=("tags:$2")
                        shift
                        ;;
                    --duration)
                        start_params+=("duration:$2")
                        shift
                        ;;
                    *)
                        echo "Error: Unsupported flag $1" >&2
                        exit 1
                        ;;
                esac
                shift
            done
            start_entry "${start_params[@]}"
            ;;
        -e|--end)
            end_entry
            shift
            ;;
        -p|--projects)
            list_projects
            shift
            ;;
        -t|--tags)
            list_tags
            shift
            ;;
        -d|--delete)
            delete_entry
            shift
            ;;
        -l|--list)
            shift
            list_params=()
            while (( "$#" )); do
                case "$1" in
                    --type)
                        list_params+=("type:$2")
                        shift 
                        ;;
                    --start)
                        list_params+=("start:$2")
                        shift
                        ;;
                    --end)
                        list_params+=("end:$2")
                        shift
                        ;;
                    *)
                        echo "Error: Unsupported flag $1" >&2
                        exit 1
                        ;;
                esac
                shift
            done
            list_entries "${list_params[@]}"
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"
