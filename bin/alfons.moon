-- alfons 5.0
-- Task execution with Lua and MoonScript
-- By daelvn
import VERSION   from require "alfons.version"
import style     from require "ansikit.style"
Path                = require "path"
unpack            or= table.unpack
printerr            = (t) -> io.stderr\write t .. "\n"

-- utils
prints     = (...)       -> printerr unpack [style arg for arg in *{...}]
printError = (text)      -> printerr style "%{red}#{text}"
errors     = (code, msg) ->
  printerr style "%{red}#{msg}"
  os.exit code
  
-- get arguments
import getopt from require "alfons.getopt"
args = getopt {...}

-- List known tasks for autocompletion
LIST_TASKS = not not args.list

-- introduction
unless LIST_TASKS
  prints "%{bold blue}Alfons #{VERSION}"


-- Optionally accept a custom file
FILE = do
  if     args.f                  then args.f
  elseif args.file               then args.file
  elseif Path.exists "Alfons.lua"  then "Alfons.lua"
  elseif Path.exists "Alfons.moon" then "Alfons.moon"
  elseif Path.exists "Alfons.tl"   then "Alfons.tl"
  else errors 1, "No Taskfile found."

-- Also accept a custom language
LANGUAGE = do
  if     FILE\match "moon$" then "moon"
  elseif FILE\match "lua$"  then "lua"
  elseif FILE\match "tl$"   then "teal"
  elseif args.type          then args.type
  else errors 1, "Cannot resolve format for Taskfile."

unless LIST_TASKS
  printerr "Using #{FILE} (#{LANGUAGE})"

-- Load string
import readMoon, readLua, readTeal from require "alfons.file"
content, contentErr = switch LANGUAGE
  when "moon" then readMoon FILE
  when "lua"  then readLua  FILE
  when "teal" then readTeal FILE
  else errors 1, "Cannot resolve format '#{LANGUAGE}' for Taskfile."
unless content then errors 1, contentErr

-- Run the taskfile
import runString from require "alfons.init"
alfons, alfonsErr = runString content, nil, true, 0, {}, {}, true
unless alfons then errors 1, alfonsErr
env = alfons ...

-- If we have to list tasks, print them and exit
if LIST_TASKS
  for k, v in pairs env.tasks
    io.write k .. ' '
  os.exit!

-- run tasks, and teardown after each of them
for command in *args.commands
  env.tasks[command] args[command]
  (rawget env.tasks, "teardown")   if rawget env.tasks, "teardown"

-- finalize
env.finalize!
