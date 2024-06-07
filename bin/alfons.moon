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

-- Read task description/arguments of a task for autocompletion
LIST_OPTIONS = args.list_options

-- Show help message
HELP = args.help

-- introduction
unless LIST_TASKS or LIST_OPTIONS
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

unless LIST_TASKS or LIST_OPTIONS
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

-- If we have to show the help message, print that and exit
if HELP
  inspect = require "inspect"
  import readFile from require "alfons.file"
  import parseComments from require "alfons.parser"
  import Paragraph, Spacer, Columns, Row, Cells, generateHelp from require "alfons.help"
  import contains from require "alfons.provide"
  -- Read the file (since MoonScript compiler deletes comments)
  raw_content = readFile FILE
  -- Parse the content
  state = parseComments raw_content
  -- Helper generators
  Option = (command, description) -> (Row Cells {
    { {color: '%{bold green}'}, command }
    { {}, description }
  })
  Task = (command, description) -> (Row Cells {
    { {color: '%{bold cyan}'}, command }
    { {}, description }
  })
  formatOptions = (option) -> (table.concat (
    for name in *option.names
      ((string.len name) > 1) and ('--' .. name) or ('-' .. name)
  ), ' ') .. ' ' .. (table.concat (
    for option_value in *option.values
      option_value.optional and "[#{option_value.value}]" or "<#{option_value.value}>"
  ), ' ')

  -- Create help message
  help_message = {
    (Paragraph 'Built-in options:')
    (Columns {padding: 2}, {
      (Option '--help [task]', 'Displays this help message, or for a specific task')
      (Option '--file -f <file>', 'Loads a custom Taskfile')
      (Option '--list', 'Lists all the tasks available for the loaded Taskfile')
      (Option '--list-options <task>', 'Lists all the options available to a task')
    })
  }
  -- If everything is hidden, just print and exit
  if state.flags.hide
    print generateHelp help_message
    os.exit!
  -- If we are asking help for a certain task, add that
  extra_message = {}
  if HELP != true
    task = state.tasks[HELP]
    if not task or (task.flags and contains task.flags, "hide")
      errors 2, "Error: Task '#{HELP}' does not exist."
    -- NOTE: We are purposefully replacing the original
    help_message = {
      (Paragraph "%{bold cyan}#{HELP}  %{reset}-  #{task.description}")
      (Columns {padding: 2}, (
        for option_name, option in pairs task.arguments
          Option (formatOptions option), option.description
      ))
    }
  -- Include tasks
  if HELP == true
    all_tasks = [k for k, v in pairs env.tasks]
    undocumented_tasks = [k for k, v in pairs env.tasks when not state.tasks[k]]
    extra_message = {
      (Spacer!)
      (Paragraph 'Loaded tasks:     (Use %{magenta}`alfons --help task`%{reset} to know more about said task)')
      (Columns {padding: 2}, [(
        Task task_name, task.description
      ) for task_name, task in pairs state.tasks when not (task.flags and contains task.flags, 'hide')])
      (Spacer!)
      (Paragraph 'Undocumented tasks:')
      (Paragraph "  %{cyan}#{table.concat undocumented_tasks, '  '}")
    }
  -- Add rest to help message
  for section in *extra_message
    table.insert help_message, section
  -- Display and exit
  print generateHelp help_message
  os.exit!
  
-- run tasks, and teardown after each of them
for command in *args.commands
  env.tasks[command] args[command]
  (rawget env.tasks, "teardown")   if rawget env.tasks, "teardown"

-- finalize
env.finalize!
