# toggl-cli

A simple CLI tool to interact with the toggl API.

## Usage

``` text
    toggl - A simple command line tool for Toggl

    Usage: toggl [options]
    
    Options:
       -h, --help       Show this help message and exit
       -a, --auth       Prompts for email and password to authenticate
       -s, --start      Start a new time entry (starting time: now)
       -e, --end        End the current time entry
       -l, --list       List time entries
       -p, --projects   List all projects
       -t, --tags       List all tags
       -d, --delete     Delete a time entry

    Declarative usage of start and list:
       -s --description <description> --tag <tag> --duration <duration>
       -l --type <now/interval> --start <start_date> --end <end_date>
    
    Note: You need to authenticate at least once before using other options.
```

## Sketchybar

This script also comes with the necessary files for usage with [sketchybar](https://github.com/FelixKratz/SketchyBar).

In order for this to work, you first need to authenticate at least once with the `-a` flag. Once that is done, use the following in your `sketchybarrc`:

```conf
sketchybar --add item toggl-view left \
  --set toggl-view \
  updates=on \
  update_freq=7 \
  script="$HOME/<path to your local clone of this repo>/toggl-view-sketchybar.sh" \
  icon=⌚︎

sketchybar --add item toggl-task1 left \
  --set toggl-task1 \
  script="$HOME/<path to your local clone of this repo>/toggl-task1-sketchybar.sh" \
  icon=🎟️ \
  --subscribe toggl-task1 mouse.clicked

sketchybar --add item toggl-task2 left \
  --set toggl-task2 \
  script="$HOME/<path to your local clone of this repo>/toggl-task2-sketchybar.sh" \
  icon=🦆 \
  --subscribe toggl-task2 mouse.clicked

sketchybar --add item toggl-stop left \
  --set toggl-stop \
  script="$HOME/<path to your local clone of this repo>/toggl-stop-sketchybar.sh" \
  icon=╳ \
  --subscribe toggl-stop mouse.clicked
```

> Add any padding or other visual features for this to fit your personal bar if needed.

With the default setup, you get 4 boxes:

- The left most box shows the currently running task
- The second one is your first defined task
- The third one is your second defined task
- And the last box is used to stop the current task

All boxes besides the first are clickable.

### Configuration

In order to ensure you get the tasks into `toggl` as you want them, you need to configure a few things first:

1. Go to `toggl-task1-sketchybar.sh`
2. Change the contents of `description`, `tags` and `duration` to whatever you want them to be
3. Do the same for `toggl-task2-sketchybar.sh`
4. If you want more than just 2 tasks, copy paste the files as many times as you like. Just make sure to increase the amount of `sketchybarrc` entries accordingly
5. Ensure the path to the script files is correct in your `sketchybarrc`
6. If you want, change the icons of the individual boxes

### Flag files

The sketchybar plugin utilizes flag files. On first start, they are created in your `/tmp/` dir. This is done to ensure that the script doesn't trigger a toggl-entry on startup. Since the files are written to `/tmp/`, they will be deleted once you reboot your device.

Unfortunately, this causes some additional effort in case you want to actively work on the way your sketchybar looks, since a `sketchybar --reload` would cause an entry to be made.
To avoid this, run `rm /tmp/toggl_task1_sketchybar_flag && sketchybar --reload` instead (you need one `rm` for each box, with the according numeration (task1, task2, etc.)).
