# watch

Watch uses `inotify` to listen for filesystem events and call the function with the path and event name. Its signature is this:

`watch (dirs:{string}, exclude:{string}, evf:{string}, pred:(file -> boolean), fn:(file -> nil)) -> nil`

## dirs

`dirs` is a list of directories to watch files in.

## exclude

`exclude` is a list of directories to exclude from the first list. If you have `.` in the first, you might want to exclude `.git`, for example.

## evf

List of events to listen for. This is the full list. Check the [inotify manpage](https://linux.die.net/man/7/inotify) for more info. Optionally you can pass a string instead of a table, accepting only one value as of now; `"live"`, which is equivalent to `{"write", "movein", "create"}`

```moon
EVENTS = {
  access:   "IN_ACCESS"
  change:   "IN_ATTRIB"
  write:    "IN_CLOSE_WRITE"
  shut:     "IN_CLOSE_NOWRITE" 
  close:    "IN_CLOSE"
  create:   "IN_CREATE"
  delete:   "IN_DELETE"
  destruct: "IN_DELETE_SELF"
  modify:   "IN_MODIFY"
  migrate:  "IN_MOVE_SELF"
  move:     "IN_MOVE"
  movein:   "IN_MOVED_TO"
  moveout:  "IN_MOVED_FROM"
  open:     "IN_OPEN"
  all:      "IN_ALL_EVENT"
}
```

## pred

The predicate function, which takes in a filename and the triggered event list(as separate arguments), and should return a boolean deciding whether to accept the event or not.

## fn

The processor function, which takes the filename and triggered event list, and is basically what should do things like compiling and such.

## Examples

### Watching MoonScript files

```moon
tasks:
  compile: =>
    watch {"."}, {".git"}, "live", (glob "*.moon"), (file, ev) -> sh "moonc #{file}"
```