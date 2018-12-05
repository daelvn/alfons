-- alfons | 02.12.2018
-- By daelvn
--> # [alfons](https://github.com/daelvn/alfons)
--> Project management helper
ltext = require "ltext"
file  = if fs then fs else require "file"
ms = if not pcall ->
    ms = require "moonscript.base"
  false

--> **Alfons** is a little script to aid with project management. Inspired by makefiles
--> (and most importantly the non-C compiling cases), it relies on exported tasks in an
--> Alfonsfile. You can write a very simple Alfonsfile just by writing:
--> ```moon
--> export task = =>
-->   print @.name
--> ```
--> This short thing will print "task" when we use `alfons task` to run it.
print ltext.title "alfons 02.12.2018"

--> These are the files that will be checked for when looking for readable scripts
files = {
  "Alfons"
  "alfons"
  "Alfons.moon"
  "Alfons.lua"
  "alfons.lua"
}

--> **get_load_fn** will return a load function depending on the langauge used
get_load_fn = (f) ->
  local lf
  if     f\match "lua"  then lf = loadfile
  elseif f\match "moon" then lf = ms.loadfile
  else
    local content
    with io.open f, "r"
      content = \read "*a"
      \close!

    lang = content\match "%-%- alfons: ?([a-z]+)"
    switch lang
      when "lua"  then lf = loadfile
      when "moon" then lf = ms.loadfile if ms
  lf

--> ## contains
--> This small functions will be useful for checking arguments.
--> It gets passed to gen_env
contains = (t, value) -> #[v for v in *t when v == value] != 0

--> ## has
--> Similar to contains, but check whenever the argument *starts* with value.
--> This is useful for arguments that take values
has = (t, argname) -> #[v for v in *t when v\match "^#{argname}"] != 0

--> **gen_env** will generate an environment based on the version we're running on
gen_env = (version) ->
  base = {
    :_G, :_VERSION, :assert, :collectgarbage, :dofile, :error, :getmetatable,
    :ipairs, :load, :loadfile, :next, :pairs, :pcall, :print, :rawequal,
    :rawget, :rawset, :require, :select, :setmetatable, :tonumber, :tostring,
    :type, :xpcall
      
    :coroutine, :debug, :io, :math, :os, :package, :string, :table

    :_VERSION

    :contains, :has
  }
  switch version
    when "lua-51"
      print ltext.dart "Generating environment for Lua 5.1 or lesser"
      base.getfenv = getfenv
      base.setfenv = setfenv
      base.module  = module
      base.unpack  = unpack
    when "lua-52"
      print ltext.dart "Generating environment for Lua 5.2"
      base.rawlen   = rawlen
      base.rawequal = rawequal
      base.bit32    = bit32
    when "lua-53"
      print ltext.dart "Generating environment for Lua 5.3 or greater"
      base.rawlen   = rawlen
      base.rawequal = rawequal
      base.utf8     = utf8
  base

--> **load_alfons** gets a filename and returns the tasks of the Alfonsfile.
load_alfons = (f) ->
  loadfn = get_load_fn f
  local env, ending
  do
    ending = tonumber _VERSION\match "Lua 5.(%d)"
    if ending <= 1 then env = gen_env "lua-51"
    if ending == 2 then env = gen_env "lua-52"
    if ending >= 3 then env = gen_env "lua-53"
  
  local alfons_fn
  do
    if ending < 2
      alfons_fn, err = loadfn f
      error "Could not load file #{f}, #{err}" if err
      setfenv alfons_fn, env
    else
      alfons_fn, err = loadfn f, "t", env, {}
      error "Could not load file #{f}, #{err}" if err

  print ltext.dart "Fetching environment..."
  alfons_fn!
  return env

--> <a name="task_kit"></a>
--> This small function will just let us pass the name of the task and two libraries
--> to the callee.
task_kit = (name, extra={}) ->
  extra_       = {}
  --> Make a shallow copy of extra, which are the unrecognized arguments, this will be our base.
  --> We store it in argl so not to clutter the extra table
  extra_.argl  = {k, v for k, v in pairs extra}
  extra_.name  = name
  extra_.ltext = ltext
  extra_.file  = file
  return extra_

--> Here, the file will be loaded and all the functions will be fetched.
print ltext.arrow "Finding files..."
local alfons
for f in *files
  print ltext.dart "Trying with #{f}"
  if file.exists f
    print ltext.bullet "Found!"
    alfons = load_alfons f
    break

--> Check if the `always` task exists. If so, run it
if alfons.always
  print ltext.arrow "Running \"always\" task"
  alfons.always task_kit "always", extra

--> We're going to run the tasks now
error "Must be called from command line!" if not arg[0]
print ltext.arrow "Reading tasks..."
--> This variable `extra` will hold our unrecognized tasks, to pass them as arguments to the next recognized task
extra = {}
--> `has_run` is used to determine whether we have to run `all` or not
has_run = false
for i=1, #arg
  print ltext.bullet arg[i], false
  --> Replace - with _
  argx = arg[i]\gsub "%-", "_"
  if argx != arg[i]
    print ltext.quote "Translating #{arg[i]} to #{argx}"
  --> Here we can see how we use [task_kit](#task_kit) to generate the self/@ argument 
  if alfons[argx]
    print ltext.bullet "Running!"
    alfons[argx] task_kit argx, extra
    --> Clear extra for the next task
    extra = {}
  else
    --> If it's not recognized, then we add it to extra
    --> Remember! We have to pass the uncorrected argument! (-)
    table.insert extra, arg[i]

--> Check if any task has been run. If it isn't the case, try to run `default`
if (not has_run) and alfons.default
  print ltext.arrow "Running \"default\" task"
  alfons.default task_kit "default", extra

--> Let's run `teardown` here.
if alfons.teardown
  print ltext.arrow "Running \"teardown\" task"
  alfons.teardown task_kit "teardown", extra

--> [daelvn](https://github.com/daelvn) · [alfons](https://alfons.daelvn.ga)
