local ltext = require("ltext")
local file
if fs then
  file = fs
else
  file = require("file")
end
local ms
if not pcall(function()
  ms = require("moonscript.base")
end) then
  ms = false
end
print(ltext.title("alfons 02.12.2018"))
local files = {
  "Alfons",
  "alfons",
  "Alfonsfile",
  "alfonsfile",
  "Taskfile",
  "taskfile",
  "Alfons.moon",
  "Alfons.lua",
  "alfons.lua"
}
local get_load_fn
get_load_fn = function(f)
  local lf
  if f:match("lua") then
    lf = loadfile
  elseif f:match("moon") then
    lf = ms.loadfile
  else
    local content
    do
      local _with_0 = io.open(f, "r")
      content = _with_0:read("*a")
      _with_0:close()
    end
    local lang = content:match("%-%- alfons: ?([a-z]+)")
    local _exp_0 = lang
    if "lua" == _exp_0 then
      lf = loadfile
    elseif "moon" == _exp_0 then
      if ms then
        lf = ms.loadfile
      end
    end
  end
  local _exp_0 = lf
  if loadfile == _exp_0 then
    print(ltext.dart("Using Lua 'loadfile'"))
  elseif ms.loadfile == _exp_0 then
    print(ltext.dart("Using MoonScript's load function"))
  end
  return lf
end
local contains
contains = function(t, value)
  return #(function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #t do
      local v = t[_index_0]
      if v == value then
        _accum_0[_len_0] = v
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)() ~= 0
end
local has
has = function(t, argname)
  return #(function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #t do
      local v = t[_index_0]
      if v:match("^" .. tostring(argname)) then
        _accum_0[_len_0] = v
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)() ~= 0
end
local act
act = function(self, t)
  local prefix = t._prefix or ""
  for argname, fn in pairs(t) do
    if contains(self.argl, prefix .. argname) then
      fn(self)
    end
  end
end
local gen_env
gen_env = function(version)
  local base = {
    _G = _G,
    _VERSION = _VERSION,
    assert = assert,
    collectgarbage = collectgarbage,
    dofile = dofile,
    error = error,
    getmetatable = getmetatable,
    ipairs = ipairs,
    load = load,
    loadfile = loadfile,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawequal = rawequal,
    rawget = rawget,
    rawset = rawset,
    require = require,
    select = select,
    setmetatable = setmetatable,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    xpcall = xpcall,
    coroutine = coroutine,
    debug = debug,
    io = io,
    math = math,
    os = os,
    package = package,
    string = string,
    table = table,
    _VERSION = _VERSION,
    contains = contains,
    has = has,
    act = act
  }
  local _exp_0 = version
  if "lua-51" == _exp_0 then
    print(ltext.dart("Generating environment for Lua 5.1 or lesser"))
    base.getfenv = getfenv
    base.setfenv = setfenv
    base.module = module
    base.unpack = unpack
  elseif "lua-52" == _exp_0 then
    print(ltext.dart("Generating environment for Lua 5.2"))
    base.rawlen = rawlen
    base.rawequal = rawequal
    base.bit32 = bit32
  elseif "lua-53" == _exp_0 then
    print(ltext.dart("Generating environment for Lua 5.3 or greater"))
    base.rawlen = rawlen
    base.rawequal = rawequal
    base.utf8 = utf8
  end
  return base
end
local load_alfons
load_alfons = function(f)
  local loadfn = get_load_fn(f)
  local env, ending
  do
    ending = tonumber(_VERSION:match("Lua 5.(%d)"))
    if ending <= 1 then
      env = gen_env("lua-51")
    end
    if ending == 2 then
      env = gen_env("lua-52")
    end
    if ending >= 3 then
      env = gen_env("lua-53")
    end
  end
  local alfons_fn
  do
    if ending < 2 then
      local err
      alfons_fn, err = loadfn(f)
      if err then
        error("Could not load file " .. tostring(f) .. ", " .. tostring(err))
      end
      setfenv(alfons_fn, env)
    else
      local err
      alfons_fn, err = loadfn(f, "t", env, { })
      if err then
        error("Could not load file " .. tostring(f) .. ", " .. tostring(err))
      end
    end
  end
  print(ltext.dart("Fetching environment..."))
  alfons_fn()
  return env
end
local task_kit
task_kit = function(name, extra)
  if extra == nil then
    extra = { }
  end
  local extra_ = { }
  do
    local _tbl_0 = { }
    for k, v in pairs(extra) do
      _tbl_0[k] = v
    end
    extra_.argl = _tbl_0
  end
  extra_.name = name
  extra_.ltext = ltext
  extra_.file = file
  return extra_
end
print(ltext.arrow("Finding files..."))
local alfons
for _index_0 = 1, #files do
  local f = files[_index_0]
  print(ltext.dart("Trying with " .. tostring(f)))
  if file.exists(f) then
    print(ltext.bullet("Found!"))
    alfons = load_alfons(f)
    break
  end
end
if not alfons then
  print(ltext.error("Could not find file"))
  os.exit()
end
if alfons.always then
  print(ltext.arrow("Running \"always\" task"))
  alfons.always(task_kit("always", extra))
end
if not arg[0] then
  error("Must be called from command line!")
end
print(ltext.arrow("Reading tasks..."))
local extra = { }
local has_run = false
for i = 1, #arg do
  print(ltext.bullet(arg[i], false))
  local argx = arg[i]:gsub("%-", "_")
  if argx ~= arg[i] then
    print(ltext.quote("Translating " .. tostring(arg[i]) .. " to " .. tostring(argx)))
  end
  if alfons[argx] then
    print(ltext.bullet("Running!"))
    alfons[argx](task_kit(argx, extra))
    has_run = true
    extra = { }
  else
    table.insert(extra, arg[i])
  end
end
if (not has_run) and alfons.default then
  print(ltext.arrow("Running \"default\" task"))
  alfons.default(task_kit("default", extra))
end
if alfons.teardown then
  print(ltext.arrow("Running \"teardown\" task"))
  return alfons.teardown(task_kit("teardown", extra))
end
