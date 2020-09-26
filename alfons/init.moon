-- alfons.init
-- API for running taskfiles
import ENVIRONMENT, KEYS, loadEnv from require "alfons.env"
import getopt                     from require "alfons.getopt"
import look                       from require "alfons.look"
provide                              = require "alfons.provide"
unpack                             or= table.unpack
inspect = require "inspect"

local *

-- run name:string, task:function, argl:table
tasks_run = 0
run       = (name, task, argl) ->
  tasks_run += 1
  self       = {k, v for k, v in pairs argl}
  self.name  = name
  self.task  = -> run name, task, argl
  task self

-- initialize a new environment
initEnv = (base=ENVIRONMENT) ->
  -- create table to be the actual environment
  env, envmt         = {:depth}, {}
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

-- TODO make teardown queue and add the teardown task to it
-- subloading another taskfile
subload = (env) -> (name, argl={}) ->
  -- FIXME an environment is initialized here but also inside subalf
  -- NOTE  subalf and alf are not the same kind of function.
  --       alf is curried load, subalf is runString
  subenv            = initEnv env
  subalf, subalfErr = runGlobal "test.alfons.#{name}"
  if subalf
    --subargs = getopt argl
    subargs = argl
    rawset subenv, "args", subargs
    rawset subenv, "uses", (cmdmd) -> provide.contains (subargs.commands or {}), cmdmd
    -- run
    sublist  = subalf unpack subargs
    subtasks = sublist.tasks or {}
    for k, v in pairs subtasks do subenv.tasks[k] = (t={}) -> run k, v, t
    rawset subenv, "load", subload subenv
    -- add to available tasks
    tasksmt         = (getmetatable env.tasks)
    fallback        = tasksmt.__index
    tasksmt.__index = (k) => (rawget @, k) or subtasks[k] or fallback k
  else
    error "triggered"

-- runString content:string, env:table, runAlways:boolean -> ... -> tasks:table
runString = (content, environment=ENVIRONMENT, runAlways=true) ->
  -- initialize environment
  env = initEnv environment
  -- load file
  alf, alfErr = loadEnv content, env
  if alfErr then return nil, "Could not run string: #{alfErr}"
  -- return with wrapper
  return (...) ->
    -- argument handling
    args = getopt {...}
    rawset env, "args", args
    -- add utils
    rawset env, "uses", (cmdmd) -> provide.contains (args.commands or {}), cmdmd
    -- run
    list  = alf args
    tasks = list.tasks or {}
    -- wrap tasks and put into environment
    for k, v in pairs tasks do env.tasks[k] = (t={}) -> run k, v, t
    -- add function for subloading
    rawset env, "load", subload env
    -- run always task
    -- FIXME says it does not exist
    env.tasks.always! if env.tasks.always and runAlways
    -- return
    return env

-- runString, but for env.load
runGlobal = (mod, environment=ENVIRONMENT) ->
  file, fileErr = look mod
  if file
    return runString (look mod), environment
  else
    return nil, fileErr

{ :run, :runString }