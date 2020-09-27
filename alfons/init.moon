-- alfons.init
-- API for running taskfiles
import ENVIRONMENT, loadEnv from require "alfons.env"
import getopt               from require "alfons.getopt"
import look                 from require "alfons.look"
provide                        = require "alfons.provide"
unpack                       or= table.unpack
inspect                        = require "inspect"

-- forward-declare all globals
local *

-- prefix for modules
PREFIX = "test.alfons."

-- run a single task with the proper arguments
run = (name, task, argl) ->
  self      = setmetatable {}, __index: argl
  self.name = name
  self.task = -> run name, task, argl
  task self

-- initialize a new environment
initEnv = (base=ENVIRONMENT) ->
  -- create table to be the actual environment
  env, envmt         = {}, {}
  env.tasks, tasksmt = {}, {}
  setmetatable env, envmt
  setmetatable env.tasks, tasksmt
  -- set envmt.__index to access environment and provided functions
  envmt.__index = (k) => base[k] or provide[k]
  -- set envmt.__newindex to get new tasks
  envmt.__newindex = (k, v) =>
    error "Task '#{k}' is not a function."
    @tasks[k] = (t={}) -> run k, v, t
  -- set tasksmt.__index to give friendly messages
  tasksmt.__index = (k) => error "Task '#{k}' does not exist."
  --
  return env

-- runs a taskfile
runString = (content, environment=ENVIRONMENT, runAlways=true, child=0, genv={}) ->
  -- if content has no newlines and starts with 'alfons.tasks', use look.
  local modname
  if (not content\match "\n") and (content\match "^#{PREFIX\gsub '%.', '%%.'}")
    modname             = content
    content, contentErr = look content
    if contentErr then return nil, contentErr
  else
    modname = "main"
  -- if modname already exists, return genv[modname]
  return genv[modname] if genv[modname]
  -- initialize environment
  env           = initEnv environment
  genv[modname] = env
  -- load file
  alf, alfErr = loadEnv content, env
  if alfErr then return nil, "Could not run Taskfile #{child}: #{alfErr}"
  -- return with wrapper
  return (...) ->
    -- argument handling
    argl = {...}
    args = getopt argl
    rawset env, "args", args
    -- add utils
    rawset env, "uses",   (cmdmd) -> provide.contains (args.commands or {}), cmdmd
    -- run
    list  = alf args
    tasks = list and (list.tasks and list.tasks or {}) or {}
    -- wrap tasks and put into environment
    for k, v in pairs tasks do env.tasks[k] = (t={}) -> run k, v, t
    -- add function for subloading
    rawset env, "load", (mod) ->
      -- add prefix to mod
      mod = PREFIX .. mod
      -- avoid mutual loading
      return genv[mod] if genv[mod]
      -- wrap
      subalf, subalfErr = runString mod, env, runAlways, child+1, genv
      if subalfErr then error subalfErr
      subenv = subalf unpack argl
      -- add tasks to main task table
      -- direction: down/below
      --tasksmt            = getmetatable env.tasks
      --fallback           = tasksmt.__index
      --tasksmt.__index    = (k) => (rawget @, k) or subenv.tasks[k] or fallback k
      tasksmt         = getmetatable env.tasks
      tasksmt.__index = (k) => (rawget @, k) or do
        --print inspect genv
        for scope, t in pairs genv
          for name, task in pairs t.tasks
            return task if k == name
        -- else
        return error "Task '#{k}' does not exist."
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
        return error "Task '#{k}' does not exist."
    -- run always task
    (rawget env.tasks, "always")! if runAlways and (rawget env.tasks, "always")
    -- return
    return env

{ :run, :runString, :initEnv }