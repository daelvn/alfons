-- alfons
-- Task executing with Lua and MoonScript
-- By daelvn
fs     or=                   require "filekit"
ak       = unless _HOST then require "ansikit.style" else {style: (x)->x\gsub "%%%b{}", ""}
unpack or= table.unpack
import style from ak

-- Compatibility
setfenv or= (fn, env) ->
  i = 1
  while true
    name = debug.getupvalue fn, i
    if name == "_ENV"
      debug.upvaluejoin fn, i, (-> env), 1
    elseif not name then break
    i += 1
  return fn
os.execute or= shell.run

-- Constants
VERSION = "3.5.1"
FILES   = {
  "Alfons.moon"
  "Alfons.lua"
}

-- Flags
--IMPORTED = false

-- Util functions
contains = (t, v) -> #[vv for vv in *t when vv == v] != 0
prints   = (text) -> print style text
printerr = (text) -> printError and (printError text) or (print style "%{red}#{text}")
readfile = (file) ->
  local contents
  with io.open "#{file}", "r"
    contents = \read "*a"
    \close!
  return contents
writefile = (file, txt) ->
  with io.open "#{file}", "w"
    \write txt
    \close!
serialize = (t) ->
  full = "return {\n"
  for k, v in pairs t
    full ..= " [\"#{k}\"] = #{v},\n"
  full ..= "}"
  return full

-- Header
prints "%{blue}Alfons #{VERSION}"

-- Collect arguments
arg or= {...}
cdir  = shell and shell.dir! or fs.currentDir!

-- Utils for the environment
local ENVIRONMENT
cmd       = (txt) -> os.execute txt
env       = setmetatable {}, __index: (i) => os.getenv i
git       = setmetatable {}, __index: (i) => (...) -> cmd "git #{i} #{table.concat {...}, ' '}"
clone     = (repo, to="") -> cmd "git clone https://github.com/#{repo}.git #{to}"
wildcard  = fs.iglob
basename  = (file) -> file\match "(.+)%..+"
extension = (file) -> file\match ".+%.(.+)"
moonc     = (i, o) -> cmd (o) and "moonc -o #{o} #{i}" or "moonc #{i}"
get       = (task) -> return setfenv (require "alfons.tasks.#{task}"), ENVIRONMENT
toflags   = (...)  -> {v, true for v in *{...}}
build     = (iter, fn) ->
  -- get modif times
  times = {}
  if fs.exists ".alfons"
    prints "%{cyan}:%{white} using .alfons"
    times = dofile ".alfons"
  --
  for file in iter
    mtime = fs.getLastModification file
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

-- Environment for Alfons files
ENVIRONMENT = {
  :_VERSION, :_HOST
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
  -- own
  :toflags
  :readfile, :writefile
  :cmd, sh: cmd
  :env
  :wildcard, :basename, :extension
  :moonc, :git
  :get, :clone
  :build
}
KEYS = [k for k, v in pairs ENVIRONMENT]

-- Get files to run
files, file = {}, ""
for node in *fs.list cdir
  continue if (node == ".") or (node == "..")
  if contains FILES, node
    table.insert files, node
-- Exit if no files were found
if #files == 0
  printerr "No Alfons file found"
  os.exit 1
-- Exit if Alfons.moon was the only file found on CC
if (#files == 1) and _HOST and files[1]\match "moon$"
  printerr "ComputerCraft cannot load Alfons.moon files"
  os.exit 1
-- If both .lua and .moon files were found, give priority to .lua
if (#files == 2)
  file = "Alfons.lua"
else
  file = files[1]

-- Turn into absolute path if CC
if _HOST
  file = fs.combine cdir, file

-- Status
print "Using #{file}"

-- If Alfons.moon is our file, simply convert to Lua
local contents
if file == "Alfons.moon"
  with fs.open file, "r"
    unless .read
      printerr "Could not open Alfons.moon"
      os.exit 1
    import to_lua from require "moonscript.base"
    contents = to_lua \read "*a"
    unless contents
      printerr "Could not read or parse Alfons.moon"
      os.exit 1
    \close!

-- Read contents of Lua file
if file == "Alfons.lua"
  with fs.open file, "r"
    unless .read
      printerr "Could not open Alfons.moon"
      os.exit 1
    contents = \read "*a"
    unless contents
      printerr "Could not read or parse Alfons.lua"
      os.exit 1
    \close!

-- Load in environment
local fn
environment = {k, v for k, v in pairs ENVIRONMENT}
if _HOST
  fn, err = load contents, "Alfons", "t", environment
  unless fn
    printerr "Could not load Alfons as function: #{err}"
    os.exit!
else
  switch _VERSION
    when "Lua 5.1"
      fn, err = loadstring contents
      unless fn
        printerr "Could not load Alfons as function: #{err}"
        os.exit 1
      setfenv fn, environment
    when "Lua 5.2", "Lua 5.3", "Lua 5.4"
      fn, err = load contents, "Alfons", "t", environment
      unless fn
        printerr "Could not load Alfons as function: #{err}"
        os.exit 1

-- Execute with arguments and get list of tasks
list = fn unpack arg
local tasks
if list
  tasks = list.tasks
else
  tasks = {k, v for k, v in pairs environment when not contains KEYS, k}

-- Check that all tasks are functions
for _name, _task in pairs tasks
  if "function" != type _task
    printerr "Task '#{_name}' is not a function"
    os.exit 1

-- Function to execute a task
tasks_run = 0
run = (name, task, argl) ->
  copy = [v for v in *argl]
  tasks_run += 1
  self = {:name}
  table.insert copy, 1, self
  task unpack copy

-- Make list of tasks available
environment.tasks = {k, ((...) -> run k, v, {...}) for k, v in pairs tasks}

-- How running tasks works:
--   All arguments passed to Alfons will be tried as rules
--   If it is a rule, arguments that come after it will be
--   passed and the rule will be run.
--   If it is not, nothing will happen.

-- If #always exists, run it
if tasks.always
  prints "%{green}->%{white} always"
  run "always", tasks.always, arg

-- Run all specified tasks +teardown
for i=1, #arg
  if tasks[arg[i]]
    prints "%{green}->%{white} #{arg[i]}"
    run arg[i], tasks[arg[i]], for j=i+1,#arg do arg[j]
    if tasks.teardown
      run "teardown", tasks.teardown, arg

-- Execute #default if no other task has been run
if tasks.default and tasks_run == 0
  prints "%{green}->%{white} default"
  run "default", tasks.default, arg