-- alfons.init
-- API for running taskfiles
import ENVIRONMENT, loadEnv from require "alfons.env"
import getopt               from require "alfons.getopt"
import look                 from require "alfons.look"
provide                        = require "alfons.provide"
unpack                       or= table.unpack

-- forward-declare all locals
local *

-- util
sanitize = (pattern) -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0" if pattern

-- prefix for modules
-- FIXME roll back from test
--PREFIX = "test.alfons."
PREFIX = "alfons.tasks."

-- initialize a new environment
initEnv = (run, base=ENVIRONMENT, genv, modname="main", pretty=false, debug_mode=false) ->
  -- create table to be the actual environment
  env, envmt         = {}, {}
  env.tasks, tasksmt = {}, {}
  setmetatable env, envmt
  setmetatable env.tasks, tasksmt
  if debug_mode
    base.debug = debug
  -- set envmt.__index to access environment and provided functions
  envmt.__index = (k) =>
    if genv and k == "__ran"
      return (getmetatable genv[modname]).__ran
    elseif genv and k == "store"
      return (getmetatable genv).store
    else
      base[k] or provide[k]
  -- set envmt.__newindex to get new tasks
  envmt.__newindex = (k, v) =>
    error "Task '#{k}' is not a function." if "function" != type v
    @tasks[k] = (t={}) -> run k, v, t
  -- set tasksmt.__index to give friendly messages
  tasksmt.__index = (k) => (rawget @, k) or do
    for scope, t in pairs genv
      for name, task in pairs t.tasks
        return task if k == name
    -- else
    if pretty
      provide.printError "Task '#{k}' does not exist."
      os.exit 1
    else
      error "Task '#{k}' does not exist."
  -- set __ran value to 0
  envmt.__ran = 0
  return env

-- runs a taskfile
runString = (content, environment=ENVIRONMENT, runAlways=true, child=0, genv={}, rqueue={}, pretty=false, debug_mode=false) ->
  return nil, "Taskfile content must be a string" unless "string" == type content
  -- if content has no newlines and starts with 'alfons.tasks', use look.
  local modname
  if (not content\match "\n") and (content\match "^#{sanitize PREFIX}")
    modname             = content
    content, contentErr = look content
    if contentErr then return nil, contentErr
  else
    modname = "main"
  -- if modname already exists, return genv[modname]
  return genv[modname] if genv[modname]
  -- add run function
  -- run a single task with the proper arguments
  run = (name, task, argl) ->
    (getmetatable genv[modname]).__ran += 1
    --print "ran tasks for #{modname}", (getmetatable genv[modname]).__ran
    self      = setmetatable {}, __index: argl
    self.name = name
    self.task = -> run name, task, argl
    callstack = (getmetatable genv).store.callstack
    table.insert callstack, name
    if (('function' != type task) and ('table' != type task))
      provide.printError "Task #{name} is not callable. Please check that it is a function."
      provide.printError "The task may be running on its own without calling it."
      os.exit 1
    -- Create error reporter
    errorHandler = (err) ->
      rewrite = err\gsub "%[string \"Alfons\"%]", "Taskfile (#{modname}:#{child})"
      provide.printError "Error in task `#{name}`:\n  #{rewrite}"
      provide.printError "  Callstack:\n    (root)"
      provide.printError "    " .. table.concat callstack, '\n    '
      os.exit 1
    ret = xpcall (() -> task self), errorHandler
    table.remove callstack, #callstack
    return ret
  -- reset genv metatable
  setmetatable genv, {store: {callstack: {}}} unless getmetatable genv
  -- initialize environment
  env           = initEnv run, environment, genv, modname, pretty, debug_mode
  genv[modname] = env
  -- load file
  alf, alfErr = loadEnv content, env
  if alfErr then return nil, "Could not load Taskfile #{child}: #{alfErr}"
  -- return with wrapper
  return (...) ->
    -- argument handling
    argl = {...}
    args = getopt argl
    rawset env, "args", args
    -- add utils
    rawset env, "uses",    (cmdmd) -> provide.contains (args.commands or {}), cmdmd
    rawset env, "exists",  (wants) ->
      for scope, t in pairs genv
        for name, task in pairs t.tasks
          return true if wants == name
      return false
    rawset env, "calls",  (cmdmd) ->
      -- get currently running task
      callstack = (getmetatable genv).store.callstack
      current   = callstack[#callstack]
      -- iterate command list and grab non-existing tasks
      on          = false
      subcommands = {}
      i           = 0
      for cmd in *args.commands
        i += 1
        if on
          break if rawget env.tasks, cmd
          subcommands[#subcommands+1] = cmd
          args.commands[i]            = nil
        else
          on = true if cmd == current
      -- remove taken commands
      args.commands = [e for i, e in provide.npairs args.commands]
      -- return
      return subcommands
    -- run
    list  = alf args
    tasks = list and (list.tasks and list.tasks or {}) or {}
    -- wrap tasks and put into environment
    for k, v in pairs tasks do env.tasks[k] = (t={}) -> run k, v, t
    -- add finalize tasks to the queue
    if fintask = (rawget env.tasks, "finalize")
      rqueue[#rqueue+1] = fintask
    -- add function for subloading
    rawset env, "load", (mod) ->
      -- add prefix to mod
      -- TODO add configurable prefix
      mod = PREFIX .. mod
      -- avoid mutual loading
      return genv[mod] if genv[mod]
      -- wrap
      subalf, subalfErr = runString mod, env, runAlways, child+1, genv, rqueue
      if subalfErr then error subalfErr
      subenv = subalf unpack argl
      -- add tasks to main task table
      -- direction: down/below
      --tasksmt            = getmetatable env.tasks
      --fallback           = tasksmt.__index
      --tasksmt.__index    = (k) => (rawget @, k) or subenv.tasks[k] or fallback k
      tasksmt         = getmetatable env.tasks
      tasksmt.__index = (k) => (rawget @, k) or do
        for scope, t in pairs genv
          for name, task in pairs t.tasks
            return task if k == name
        -- else
        if pretty
          provide.printError "Task '#{k}' does not exist."
          os.exit 1
        else
          error "Task '#{k}' does not exist."
      -- make the main tasks table accessible to the subloaded task table
      -- direction: up/above
      --subtasksmt         = getmetatable subenv.tasks
      --subfallback        = subtasksmt.__index
      --subtasksmt.__index = (k) => (rawget @, k) or env.tasks[k] or subfallback k
      subtasksmt         = getmetatable subenv.tasks
      subtasksmt.__index = (k) => (rawget @, k) or do
        for scope, t in pairs genv
          for name, task in pairs t.tasks
            return task if k == name
        -- else
        if pretty
          provide.printError "Task '#{k}' does not exist."
          os.exit 1
        else
          error "Task '#{k}' does not exist."
    -- run always task
    if runAlways and (rawget env.tasks, "always")
      (rawget env.tasks, "always")!
      (getmetatable genv[modname]).__ran -= 1
    -- add trigger for default and finalize tasks
    rawset env, "finalize", ->
      -- default
      for scope, t in pairs genv
        --print "ran for #{scope}", t.__ran
        (rawget t.tasks, "default")! if (rawget t.tasks, "default") and t.__ran < 1
      -- finalize
      rqueue[i]! for i=#rqueue, 1, -1
    -- return
    return env

{ :runString, :initEnv }
