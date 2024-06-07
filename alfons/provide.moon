-- alfons.provide
-- Functions provided to the environment
import style                from require "ansikit.style"
import listAll, glob, iglob from require "alfons.wildcard"
Path                           = require "path"
fs                             = require "path.fs"
unpack                       or= table.unpack
printerr                       = (t) -> io.stderr\write t .. "\n" 

-- try loading inotify, which is an optional dependancy
inotify = do
  ok, inotify = pcall -> require "inotify"
  ok and inotify or nil

-- contains (t:table, v:any) -> boolean
-- Checks whether a table contains a value
contains = (t, v) -> #[vv for vv in *t when vv == v] != 0

--# io #--
-- prints (...) -> nil
-- Print + style
prints = (...) -> printerr unpack [style arg for arg in *{...}]

-- printError (text:string) -> nil
-- Prints an error
printError = (text) -> printerr style "%{red}#{text}"

-- safeOpen (path:string, mode:string) -> io | table
-- Filekit's safeOpen
safeOpen = (path, mode) ->
  a, b = io.open path, mode
  return a and a or {error: b}

-- safePopen (path:string, mode:string) -> io | table
safePopen = (path, mode) ->
  return {error: "io.popen is not available"} unless io.popen
  handle = io.popen path, mode
  return handle or {error: "Could not io.popen #{path}"}

-- readfile (file:string) -> string
-- Returns the contents of a file
readfile = (file) ->
  with safeOpen file, "r"
    if .error
      error .error
    else
      contents = \read "*a"
      \close!
      return contents

-- writefile (file:string, content:string) -> nil
-- Writes into a file
writefile = (file, content) ->
  with safeOpen file, "w"
    if .error
      error .error
    else
      \write content
      \close!

-- serialize (t:table) -> string
-- Quick and dirty serialize function
serialize = (t) ->
  full = "return {\n"
  for k, v in pairs t
    full ..= "  ['#{k}'] = '#{v}',"
  full ..= "}"
  return full

-- ask (str:string) -> string
-- Gets input from the user, with a prompt (optionally styled).
ask = (str) ->
  io.write style str
  return io.read!

-- show (str:string) -> nil
-- Displays a message, but fancy
show = (str) -> prints "%{cyan}:%{white} #{str}"

-- env {string:string}
-- Proxy table to os.getenv
env = setmetatable {}, __index: (i) => os.getenv i

--# commands #--
-- cmd (str:string) -> number
-- os.execute
cmd = os.execute
sh  = cmd

-- cmdfail (str:string) -> nil
-- os.execute, but quits on fail
cmdfail = (str) ->
  code = cmd str
  os.exit code unless code == 0
shfail  = cmdfail

-- cmdread (cmd:string) -> string
-- opens a command and returns its output or error message
cmdread = (cmd, raw) ->
  with safePopen cmd, "r"
    if .error
      error .error
      return .error
    else
      contents = \read "*a"
      \close!
      return contents
shread = cmdread

--# path #--
basename   = (file) -> file\match "(.+)%..+"     -- basename   (file:string) -> string
filename   = Path.stem                           -- filename   (file:string) -> string
extension  = Path.suffix                         -- extension  (file:string) -> string
pathname   = Path.parent                         -- pathname   (file:string) -> string
isAbsolute = (path) -> path\match "^/"           -- isAbsolute (path:string) -> string

--# fs #--
-- wildcard (path:string) -> function (iterator)
-- Implements old wildcard behavior
wildcard = iglob

-- iwildcard (paths:table) -> function (iterator)
-- Multiple fs.iglob paths
iwildcard = (paths) ->
  all = {}
  for path in *paths
    for globbed in iglob path
      table.insert all, globbed
  --
  i, n = 0, #all
  ->
    i += 1
    return all[i] if i <= n

-- isEmpty (path:string) -> boolean
-- Checks if a directory is empty
isEmpty = (path) ->
  return false unless Path.isdir path
  return 0 == #(listAll path)

-- delete (loc:string)
-- Recursive delete
delete = (loc) ->
  return unless Path.exists loc
  if Path.isfile loc or isEmpty loc
    --print "DELFILE #{loc}"
    fs.remove loc
  else
    --print "DELDIR #{loc}"
    for node in fs.dir loc
      --print "SUBDEL #{node}"
      continue if node\match "%.%."
      --delete Path loc, node
      delete node
    fs.remove loc

-- copy (source:string, target:string)
-- Recursive copy
copy = (fr, to) ->
  error "copy $ #{fr} does not exist" unless Path.exists fr
  if Path.isdir fr
    error "copy $ #{to} already exists" if Path.exists to
    fs.mkdir to
    for node in fs.dir fr
      --copy (Path fr, node), (Path to, node)
      copy node, (Path to, (Path.name node))
  elseif Path.isfile fr
    fs.copy fr, to

-- glob (glob:string) -> (path:string) -> boolean
-- Curried fs.matchGlob
-- NOTE deleted in 5.0
--glob = (glob) -> (path) -> fs.matchGlob (fs.fromGlob glob), path

-- build (iter:function, fn:function) -> nil
-- Compares last modification times with a cache, and if the file was
-- modified, it passes the file to fn.
build = (iter, fn) ->
  -- get modification times
  times = {}
  if Path.exists ".alfons"
    prints "%{cyan}:%{white} using .alfons"
    times = dofile ".alfons"
    times = {k, tonumber v for k, v in pairs times}
  --
  for file in iter
    mtime = fs.mtime file
    if times[file]
      -- previously built
      fn file if mtime > times[file]
      times[file] = mtime
    else
      -- never built before
      fn file
      times[file] = mtime
  -- write back to file
  writefile ".alfons", serialize times

-- EVENTS {string:string}
EVENTS = {
  access:   "IN_ACCESS"         --  "accessed"}
  change:   "IN_ATTRIB"         --  "changed"}
  write:    "IN_CLOSE_WRITE"    --  "written into"}
  shut:     "IN_CLOSE_NOWRITE"  --  "closed without writing"}
  close:    "IN_CLOSE"          --  "closed"}
  create:   "IN_CREATE"         --  "created"}
  delete:   "IN_DELETE"         --  "deleted"}
  destruct: "IN_DELETE_SELF"    --  "deleted"}
  modify:   "IN_MODIFY"         --  "modified"}
  migrate:  "IN_MOVE_SELF"      --  "migrated"}
  move:     "IN_MOVE"           --  "moved"}
  movein:   "IN_MOVED_TO"       --  "moved here"}
  moveout:  "IN_MOVED_FROM"     --  "moved from here"}
  open:     "IN_OPEN"           --  "opened"}
  all:      "IN_ALL_EVENTS"     --  "updated"}
}

-- do not export this
-- https://stackoverflow.com/a/32387452
bit_band = (a, b) ->
  result, bitval = 0, 1
  while a > 0 and b > 0
    if a % 2 == 1 and b % 2 == 1
      result = result + bitval
    bitval = bitval * 2
    a = math.floor a/2
    b = math.floor b/2
  return result

-- watch1 (iter:function, evf:table/string, fn:function) -> nil
-- Uses inotify to watch for events specified in the event table.
-- evf == "live" -> {"write", "movein", "modify", "create", "migrate"}
-- watch1 = (iter, evf, fn) ->
--   handle  = inotify.init!
--   -- do equivalents
--   if evf == "live"
--     evf = {"write", "movein", "create"}
--   --handles = {}
--   -- get file list
--   files = {file, true for file in iter}
--   prints "%{cyan}:%{white} Watching for:"
--   for file, _ in pairs files
--     prints "  - %{green}#{file}"
--   -- get directories
--   dirs = {}
--   for file, _ in pairs files
--     parent       = pathname file
--     dirs[parent] = true unless dirs[parent]
--   prints "%{cyan}:%{white} inotify directories:"
--   for dir, _ in pairs dirs
--     prints "  - %{blue}#{dir}"
--   events = [inotify[EVENTS[ev]] for ev in *evf]
--   -- add file watchers
--   -- note: you can only add dirs here
--   watchers = {}
--   for dir, _ in pairs dirs
--     -- create a main watcher
--     watchers[dir] = handle\addwatch dir, unpack events
--   reversed = {v, k for k, v in pairs watchers}
--   -- now loop
--   while true
--     events = handle\read!
--     break unless events -- error?
--     -- iterate fetched events
--     for ev in *events
--       -- get full path
--       full = reversed[ev.wd] .. (ev.name or "")
--       -- get action names
--       actions = {}
--       for action, evt in pairs EVENTS
--         continue if action == "all"
--         if 0 != bit_band ev.mask, inotify[evt]
--           table.insert actions, action
--       -- execute fn
--       prints "%{cyan}:%{white} Triggered %{magenta}#{table.concat actions, ', '}%{white}: %{yellow}#{full}"
--       fn full
--   -- close it
--   handle\close!

-- watch (dirs:{string}, exclude:{string}, evf:{string}, pred:(file -> boolean), fn:(file -> nil)) -> nil
watch = (dirs, exclude, evf, pred, fn) ->
  error "Could not load inotify" unless inotify
  handle  = inotify.init!
  -- do equivalents
  if evf == "live"
    evf = {"write", "movein"}
  -- convert all into absolute
  cdir = Path.cwd!
  for i, dir in ipairs dirs
    unless isAbsolute dir
      --dirs[i] = fs.reduce fs.combine cdir, dir
      dirs[i] = Path cdir, dir
  for i, dir in ipairs exclude
    unless isAbsolute dir
      --exclude[i] = fs.reduce fs.combine cdir, dir
      exclude[i] = Path cdir, dir
  -- recurse into subdirectories
  for i, dir in ipairs dirs
    for ii, subdir in ipairs listAll dir
      doBreak = false
      for exclusion in *exclude
        doBreak = true if subdir\match "^#{exclusion}"
      continue if doBreak
      table.insert dirs, subdir if Path.isdir subdir
  -- print dirs
  prints "%{cyan}:%{white} Watching for:"
  for dir in *dirs
    prints "  - %{green}#{dir}"
  -- get events
  events = [inotify[EVENTS[ev]] for ev in *evf]
  -- add create to event list
  -- evf  -> full event list
  -- uevf -> user event list
  uevf = {k, v for k, v in pairs evf}
  unless contains evf, "create"
    table.insert evf, "create"
    table.insert events, inotify.IN_CREATE
  -- add watchers
  watchers = {}
  for dir in *dirs
    watchers[dir] = handle\addwatch dir, unpack events
  reversed = {v, k for k, v in pairs watchers}
  -- now iterate
  while true
    evts = handle\read!
    break unless evts -- error?
    -- iterate fetched events
    for ev in *evts
      -- get full path
      full = Path reversed[ev.wd], (ev.name or "")
      -- if dir, add watcher
      if (Path.isdir full) and (bit_band ev.mask, inotify.IN_CREATE) and not watchers[full]
        prints "%{cyan}:%{white} Added to watchlist: %{green}#{full}"
        watchers[full]           = handle\addwatch full, unpack events
        reversed[watchers[full]] = full
      -- get action names
      actions = {}
      for action, evt in pairs EVENTS
        continue if action == "all"
        if 0 != bit_band ev.mask, inotify[evt]
          table.insert actions, action if contains uevf, action
      -- skip if we have no matching actions
      continue if #actions == 0
      -- check that it passes predicate
      continue unless pred full, actions
      -- execute fn
      prints "%{cyan}:%{white} Triggered %{magenta}#{table.concat actions, ', '}%{white}: %{yellow}#{full}"
      fn full, actions
  -- close it
  handle\close!
--watch {"."}, {".git"}, "live", (glob "*.moon"), => sh "moonc #{@}"

-- npairs (table) -> -> number, *
-- ipairs, but does not stop if nil is found
npairs = (t) ->
  keys = [k for k, v in pairs t when "number" == type k]
  table.sort keys
  i    = 0
  n    = #keys
  ->
    i += 1
    return keys[i], t[keys[i]] if i <= n


--# utils #--

-- lines (string) -> [string]
-- Split a string into lines
lines = (str) -> [line for line in str\gmatch "[^\r\n]+"]

-- split (str:string, re:pattern, plain:boolean, n:number) -> [string]
--   str - String to split
--   re - Pattern to split the text by
--   plain - Whether to treat `re` as plaintext or a Lua pattern (defaults to false)
--   n - Maximum matches (defaults to none)
-- https://github.com/lunarmodules/Penlight/blob/master/lua/pl/utils.lua
split = (str, re, plain, n) ->
  i1, ls = 1, {}
  if not re then re = '%s+'
  if re == '' then return { str }
  while true
    i2, i3 = string.find str, re, i1, plain
    if not i2
      last = string.sub str, i1
      if last != '' then table.insert ls, last
      if #ls == 1 and ls[1] == ''
        return {}
      else
        return ls

    table.insert ls, string.sub str, i1, i2-1

    if n and #ls == n then
      ls[#ls] = string.sub str, i1
      return ls

    i1 = i3+1

-- filter (arr:[*], predicate:((value:*, key:*) -> boolean)) -> [*]
-- Filters a table using a predicate
filter = (arr, predicate) -> [v for k, v in ipairs arr when predicate v, k]

-- map (arr:[*], predicate:((value: *, key: *) -> *)) -> [*]
-- Normal map over a table
map = (arr, predicate) -> [predicate v, k for k, v in ipairs arr]

-- reduce (arr:[*], predicate:((accum:*, value: *) -> *), initial:*) -> *
-- reduce/foldl
reduce = (arr, predicate, initial) ->
  accumulator = initial or arr[1]
  start = initial and 0 or 1
  for i = start, i < #arr
    accumulator = predicate accumulator, arr[i]
  return accumulator

-- slice (arr:[*], start:number?, end:number?) -> [*]
-- Creates a slice of an array
slice = (arr, start, _end) -> 
  if not start and not _end return arr
  if start and not _end return [v for v in *arr[start,]]
  if not start and _end return [v for v in *arr[,_end]]
  return [v for v in *arr[start,_end]]

-- contains (arr:[*], value:*) -> boolean
-- Check if an array contains a value
contains = (arr, value) -> for v in *arr
  return true if v == value

-- keys (tbl:{*:*}) -> [*]
-- Returns all the keys of a table
keys = (tbl) -> [k for k, v in pairs tbl]

-- sanitize (string) -> string
-- Pattern-escapes a string
sanitize = (pattern="") -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0"

{
  :contains
  :prints, :printError
  :readfile, :writefile, :serialize
  :cmd, :cmdfail, :sh, :shfail, :cmdread, :shread
  :wildcard, :iwildcard, :glob
  :basename, :filename, :extension, :pathname
  :build, :watch
  :env, :ask, :show
  :npairs
  :listAll, :safeOpen, :safePopen
  :isEmpty, :delete, :copy
  :lines, :split, :filter, :map, :reduce
  :slice, :keys, :contains
  :sanitize
}
