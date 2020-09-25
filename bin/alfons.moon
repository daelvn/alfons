-- alfons 4
-- Task execution with Lua and MoonScript
-- By daelvn
import VERSION            from require "alfons.version"
import prints, printError from require "alfons.provide"
setfenv                    or= require "alfons.setfenv"
fs                           = require "filekit"

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
  else
    printError "No Alfonsfile found."
    os.exit 1

-- Also accept a custom language
LANGUAGE = do
  if     FILE\match "moon$" then "moon"
  elseif FILE\match "lua$"  then "lua"
  elseif args.type          then args.type
  else
    printError "Cannot resolve format for Alfonsfile."
    os.exit 1
print "Using #{FILE} (#{LANGUAGE})"

-- read alfonsfile
import readMoon, readLua          from require "alfons.file"
import ENVIRONMENT, KEYS, loadEnv from require "alfons.env"
content, contentErr = switch LANGUAGE
  when "moon" then readMoon FILE
  when "lua"  then readLua  FILE
  else
    printError "Cannot resolve format '#{LANGUAGE}' for Alfonsfile."
    os.exit 1
unless content
  printError contentErr
  os.exit 1

-- create local copy of environment
import contains from require "alfons.provide"
environment      = {k, v for k, v in pairs ENVIRONMENT}
environment.args = args
environment.uses = (cmdmd) -> contains (args.commands or {}), cmdmd

-- load tasks
alfons, alfonsErr = loadEnv content, environment
unless alfons
  printError alfonsErr
  os.exit 1
list = alfons args
local tasks
if list
  tasks = list.tasks
else
  tasks = {k, v for k, v in pairs environment when not contains KEYS, k}

-- check that all tasks are functions
for tname, ttask in pairs tasks
  if "function" != type ttask
    printError "alfons :: Task '#{tname}' is not a function"
    os.exit 1

-- function to execute a task
tasks_run = 0
run       = (name, task, argl) ->
  tasks_run += 1
  self       = {k, v for k, v in pairs argl}
  self.name  = name
  self.task  = -> run name, task, argl
  task self

-- create self-referencing tables and functions
environment.tasks = {k, ((t={}) -> run k, v, t) for k, v in pairs tasks}
environment.load  = (mod) ->
  loadtasks = require "alfons.tasks.#{mod}"
  for tname, ttask in pairs loadtasks.tasks
    if "function" == type ttask
      setfenv ttask, environment
      tasks[tname]             = ttask
      environment.tasks[tname] = (t={}) -> run tname, ttask, t

-- If #always exists, run it before anything
if tasks.always
  prints "%{green}->%{white} always"
  run "always", tasks.always, args.always or {}

-- Run all tasks and teardown after each of them
for command in *args.commands
  if tasks[command]
    prints "%{green}->%{white} #{command}"
    run command, tasks[command], args[command] or {}
    if tasks.teardown
      run "teardown", tasks.teardown, args.teardown or {}

-- Execute #default if no other task has been run
if tasks.default and tasks_run == 0
  prints "%{green}->%{white} default"
  run "default", tasks.default, args.default or {}
