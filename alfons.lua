local fs = fs or require("filekit")
local ak
if not (_HOST) then
  ak = require("ansikit.style")
else
  ak = {
    style = function(x)
      return x:gsub("%%%b{}", "")
    end
  }
end
local unpack = unpack or table.unpack
local style
style = ak.style
local VERSION = "3.1"
local FILES = {
  "Alfons.moon",
  "Alfons.lua"
}
local contains
contains = function(t, v)
  return #(function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #t do
      local vv = t[_index_0]
      if vv == v then
        _accum_0[_len_0] = vv
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)() ~= 0
end
local prints
prints = function(text)
  return print(style(text))
end
local printerr
printerr = function(text)
  return printError and (printError(text)) or (print(style("%{red}" .. tostring(text))))
end
prints("%{blue}Alfons " .. tostring(VERSION))
local arg = arg or {
  ...
}
local cmd
cmd = function(txt)
  return os.execute(txt)
end
local env = setmetatable({ }, {
  __index = function(self, i)
    return os.getenv(i)
  end
})
local git = setmetatable({ }, {
  __index = function(self, i)
    return function(...)
      return sh("git " .. tostring(i) .. " " .. tostring(table.concat({
        ...
      }, ' ')))
    end
  end
})
local wildcard = fs.iglob
local basename
basename = function(file)
  return file:match("(.+)%..+")
end
local extension
extension = function(file)
  return file:match(".+%.(.+)")
end
local moonc
moonc = function(i, o)
  return cmd((o) and "moonc -o " .. tostring(o) .. " " .. tostring(i) or "moonc " .. tostring(i))
end
local cdir = shell and shell.dir() or fs.currentDir()
local files, file = { }, ""
local _list_0 = fs.list(cdir)
for _index_0 = 1, #_list_0 do
  local _continue_0 = false
  repeat
    local node = _list_0[_index_0]
    if (node == ".") or (node == "..") then
      _continue_0 = true
      break
    end
    if contains(FILES, node) then
      table.insert(files, node)
    end
    _continue_0 = true
  until true
  if not _continue_0 then
    break
  end
end
if #files == 0 then
  printerr("No Alfons file found")
  os.exit()
end
if (#files == 1) and _HOST and files[1]:match("moon$") then
  printerr("ComputerCraft cannot load Alfons.moon files")
  os.exit()
end
if (#files == 2) then
  file = "Alfons.lua"
else
  file = files[1]
end
if _HOST then
  file = fs.combine(cdir, file)
end
print("Using " .. tostring(file))
local contents
if file == "Alfons.moon" then
  do
    local _with_0 = fs.open(file, "r")
    if not (_with_0.read) then
      printerr("Could not open Alfons.moon")
      os.exit()
    end
    local to_lua
    to_lua = require("moonscript.base").to_lua
    contents = to_lua(_with_0:read("*a"))
    if not (contents) then
      printerr("Could not read or parse Alfons.moon")
      os.exit()
    end
    _with_0:close()
  end
end
if file == "Alfons.lua" then
  do
    local _with_0 = fs.open(file, "r")
    if not (_with_0.read) then
      printerr("Could not open Alfons.moon")
      os.exit()
    end
    contents = _with_0:read("*a")
    if not (contents) then
      printerr("Could not read or parse Alfons.lua")
      os.exit()
    end
    _with_0:close()
  end
end
local ENVIRONMENT = {
  _VERSION = _VERSION,
  _HOST = _HOST,
  assert = assert,
  error = error,
  pcall = pcall,
  xpcall = xpcall,
  tonumber = tonumber,
  tostring = tostring,
  select = select,
  type = type,
  pairs = pairs,
  ipairs = ipairs,
  next = next,
  unpack = unpack,
  require = require,
  print = print,
  io = io,
  math = math,
  string = string,
  table = table,
  os = os,
  fs = fs,
  cmd = cmd,
  sh = cmd,
  env = env,
  wildcard = wildcard,
  basename = basename,
  extension = extension,
  moonc = moonc,
  git = git
}
local KEYS
do
  local _accum_0 = { }
  local _len_0 = 1
  for k, v in pairs(ENVIRONMENT) do
    _accum_0[_len_0] = k
    _len_0 = _len_0 + 1
  end
  KEYS = _accum_0
end
local fn
local environment
do
  local _tbl_0 = { }
  for k, v in pairs(ENVIRONMENT) do
    _tbl_0[k] = v
  end
  environment = _tbl_0
end
if _HOST then
  local err
  fn, err = load(contents, "Alfons", "t", environment)
  if not (fn) then
    printerr("Could not load Alfons as function: " .. tostring(err))
    os.exit()
  end
else
  local _exp_0 = _VERSION
  if "Lua 5.1" == _exp_0 then
    local err
    fn, err = loadstring(contents)
    if not (fn) then
      printerr("Could not load Alfons as function: " .. tostring(err))
      os.exit()
    end
    setfenv(fn, environment)
  elseif "Lua 5.2" == _exp_0 or "Lua 5.3" == _exp_0 or "Lua 5.4" == _exp_0 then
    local err
    fn, err = load(contents, "Alfons", "t", environment)
    if not (fn) then
      printerr("Could not load Alfons as function: " .. tostring(err))
      os.exit()
    end
  end
end
local list = fn(unpack(arg))
local tasks
if list then
  tasks = list.tasks
else
  do
    local _tbl_0 = { }
    for k, v in pairs(environment) do
      if not contains(KEYS, k) then
        _tbl_0[k] = v
      end
    end
    tasks = _tbl_0
  end
end
local tasks_run = 0
local run
run = function(name, task, argl)
  local copy
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #argl do
      local v = argl[_index_0]
      _accum_0[_len_0] = v
      _len_0 = _len_0 + 1
    end
    copy = _accum_0
  end
  tasks_run = tasks_run + 1
  local self = {
    name = name
  }
  table.insert(copy, 1, self)
  return task(unpack(copy))
end
if tasks.always then
  prints("%{green}->%{white} always")
  run("always", tasks.always, arg)
end
for i = 1, #arg do
  if tasks[arg[i]] then
    prints("%{green}->%{white} " .. tostring(arg[i]))
    run(arg[i], tasks[arg[i]], (function()
      local _accum_0 = { }
      local _len_0 = 1
      for j = i + 1, #arg do
        _accum_0[_len_0] = arg[j]
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)())
    if tasks.teardown then
      run("teardown", tasks.teardown, arg)
    end
  end
end
if tasks.default and tasks_run == 0 then
  prints("%{green}->%{white} default")
  return run("default", tasks.default, arg)
end
