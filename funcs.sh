#!/bin/bash

source ./constants.sh
source ./env

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
    blue_text "toggl - A simple command line tool for Toggl"
    echo
    blue_text "Usage: toggl [options]"
    echo
    yellow_text "Options:"
    yellow_text "  -h, --help      Show this help message and exit"
    yellow_text "  -a, --auth      Starts the authorization process"
}


### AUTHENTICATION ###

function credentials_check() {
    if [ -f "$credentials_file" ]; then
        echo "You've already authenticated"
        exit 0
    else
        mkdir -p "$(dirname "$credentials_file")"
        touch "$credentials_file"
    fi
}

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

# get credentials
function auth() {

    credentials_check

    yellow_text "This is the first time you're using this tool. Let's authenticate you."
    
    read -p "Enter your email: " email
    read_password

    echo -e "email=$email\npassword=$password" | base64 > $credentials_file

}