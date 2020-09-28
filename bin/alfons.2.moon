-- alfons 4.2
-- Task execution with Lua and MoonScript
-- By daelvn
import VERSION   from require "alfons.version"
import style     from require "ansikit.style"
fs                  = require "filekit"
setfenv           or= require "alfons.setfenv"
unpack            or= table.unpack

-- utils
prints     = (...)       -> print unpack [style arg for arg in *{...}]
printError = (text)      -> print style "%{red}#{text}"
errors     = (code, msg) ->
  print style "%{red}#{msg}"
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
  else errors 1, "No Alfonsfile found."

-- Also accept a custom language
LANGUAGE = do
  if     FILE\match "moon$" then "moon"
  elseif FILE\match "lua$"  then "lua"
  elseif args.type          then args.type
  else errors 1, "Cannot resolve format for Alfonsfile."
print "Using #{FILE} (#{LANGUAGE})"

-- Load string
import readMoon, readLua from require "alfons.file"
content, contentErr = switch LANGUAGE
  when "moon" then readMoon FILE
  when "lua"  then readLua  FILE
  else errors 1, "Cannot resolve format '#{LANGUAGE}' for Alfonsfile."
unless content then errors 1, contentErr

-- Run the taskfile
import runString from require "alfons"
alfons, alfonsErr = runString content
unless alfons then errors 1, alfonsErr
env = alfons unpack args -- FIXME i might not need unpack here?

-- run tasks, and teardown after each of them
-- TODO consider a variable for letting the task know if it was loaded or run from CLI
for command in *args.commands
  env.tasks[command]!            if env.tasks[command]
  (rawget env.tasks, "teardown") if rawget env.tasks, "teardown"

-- TODO add finalize mechanism for running `default` and `finalize`.
env.finalize!