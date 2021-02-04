-- alfons 4.2
-- Task execution with Lua and MoonScript
-- By daelvn
import VERSION   from require "alfons.version"
import style     from require "ansikit.style"
fs                  = require "filekit"
unpack            or= table.unpack
printerr            = (t) -> io.stderr\write t .. "\n"

-- utils
prints     = (...)       -> printerr unpack [style arg for arg in *{...}]
printError = (text)      -> printerr style "%{red}#{text}"
errors     = (code, msg) ->
  printerr style "%{red}#{msg}"
  os.exit code
  
-- introduction
prints "%{bold blue}Alfons #{VERSION}"

-- get arguments
import getopt from require "alfons.getopt"
args = getopt {...}

-- optionally accept a custom file
FILE = do
  if     args.f                  then args.f
  elseif args.file               then args.file
  elseif fs.exists "Alfons.lua"  then "Alfons.lua"
  elseif fs.exists "Alfons.moon" then "Alfons.moon"
  elseif fs.exists "Alfons.tl"   then "Alfons.tl"
  else errors 1, "No Taskfile found."

-- Also accept a custom language
LANGUAGE = do
  if     FILE\match "moon$" then "moon"
  elseif FILE\match "lua$"  then "lua"
  elseif FILE\match "tl$"   then "teal"
  elseif args.type          then args.type
  else errors 1, "Cannot resolve format for Taskfile."
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

-- run tasks, and teardown after each of them
for command in *args.commands
  env.tasks[command] args[command] if rawget env.tasks, command
  (rawget env.tasks, "teardown")   if rawget env.tasks, "teardown"

-- finalize
env.finalize!