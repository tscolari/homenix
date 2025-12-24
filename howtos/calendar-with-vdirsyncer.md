# Configure calendar with vdirsyncer:

at ~/.config/vdirsyncer/config:

```
[general]
status_path = "~/.local/share/vdirsyncer/status/"

[pair work_calendar]
a = "work_calendar_local"
b = "work_calendar_remote"
collections = null

[storage work_calendar_local]
type = "singlefile"
path = "~/.config/vdir/calendars/work.ics"

[storage work_calendar_remote]
type = "http"
url = "PATH TO SECRET CALENDAR URL"
read_only = true
```

This will create the `~/.config/vdir/calendars/work.ics` file and keep it updated.
Ensure vdirsyncer is running too:
`systemctl --user enable vdirsyncer.timer`

# Khal:

For Khal you need to import that file with `khal import`

# Calcure

For Calcure, that file need to be added to the list: `ics_event_files = ~/.config/vdir/calendars/work.ics`
