-- alfons.init
-- API for running taskfiles
import ENVIRONMENT, KEYS, loadEnv from require "alfons.env"
import getopt                     from require "alfons.getopt"
import look                       from require "alfons.look"
provide                              = require "alfons.provide"

-- run name:string, task:function, argl:table
tasks_run = 0
run       = (name, task, argl) ->
  tasks_run += 1
  print tasks_run, name
  self       = {k, v for k, v in pairs argl}
  self.name  = name
  self.task  = -> run name, task, argl
  task self

-- runString content:string, environment:table -> ... -> tasks:table
runString = (content, environment=ENVIRONMENT) ->
  -- create table to be the actual environment
  env, envmt = {tasks: {}}, {}
  setmetatable env, envmt
  -- set __index to access environment
  envmt.__index = (k) => environment[k] or provide[k]
  -- set __newindex to get new tasks
  envmt.__newindex = (k, v) =>
    error "Task '#{k}' is not a function."
    @tasks[k] = (t={}) -> run k, v, t
  -- load file
  alf, alfErr = loadEnv content, env
  return nil, "Could not run string: #{alfErr}" if err
  -- return with wrapper
  (...) ->
    -- argument handling
    args     = getopt {...}
    rawset env, "args", args
    -- add utils
    rawset env, "uses", (cmdmd) -> provide.contains (args.commands or {}), cmdmd
    -- run
    list  = alf args
    -- collect all tasks into a single table
    tasks = list.tasks or {}
    -- wrap tasks
    etasks = {}
    for k, v in pairs tasks do etasks[k] = (t={}) -> run k, v, t
    -- 
    -- return
    return etasks, env

-- runString, but for env.load
runGlobal = (mod, environment=ENVIRONMENT) ->
  file, fileErr = look mod
  if file
    return runString (look mod), environment
  else
    return nil, fileErr

{ :run, :runString }