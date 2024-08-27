# toggl-cli

A simple CLI tool to interact with the toggl API.

## Usage

``` text
    toggl - A simple command line tool for Toggl

    Usage: toggl [options]
    
    Options:
       -h   Show this help message and exit
       -a   Prompts for email and password to authenticate
       -s   Start a new time entry (starting time: now)
       -e   End the current time entry
       -l   List time entries
       -p   List all projects
       -t   List all tags
       -d   Delete a time entry

    Declarative usage of start and list:
       -s --description <description> --tag <tag> --duration <duration>
       -l --type <now/interval> --start <start_date> --end <end_date>
    
    Note: You need to authenticate at least once before using other options.
```

 