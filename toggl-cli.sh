#!/bin/bash

source funcs.sh

# echo to create an empty line at the beginning of the output
echo

while getopts "haseptdcl" opt; do
    case ${opt} in
        h )
            help
            ;;
        a )
            auth
            ;;
        s )
            start_entry
            ;;
        e )
            end_entry
            ;;
        p )
            list_projects
            ;;
        t )
            list_tags
            ;;
        d )
            delete_entry
            ;;
        c )
            continue_entry
            ;;
        l )
            list_entries
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            exit 1
            ;;
    esac
done