do

do
local _ENV = _ENV
package.preload[ "alfons.compat" ] = function( ... ) local arg = _G.arg;
local setfenv = setfenv or function(fn, env)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if name == "_ENV" then
      debug.upvaluejoin(fn, i, (function()
        return env
      end), 1)
    elseif not name then
      break
    end
    i = i + 1
  end
  return fn
end
return {
  setfenv = setfenv
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.env" ] = function( ... ) local arg = _G.arg;
local setfenv
setfenv = require("alfons.compat").setfenv
local style
style = require("ansikit.style").style
local fs = require("filekit")
local provide = require("alfons.provide")
local ENVIRONMENT
ENVIRONMENT = {
  _VERSION = _VERSION,
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
  style = style,
  io = io,
  math = math,
  string = string,
  table = table,
  os = os,
  fs = fs
}
for k, v in pairs(provide) do
  ENVIRONMENT[k] = v
end
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
local loadEnv
loadEnv = function(content, env)
  local fn
  local _exp_0 = _VERSION
  if "Lua 5.1" == _exp_0 then
    local err
    fn, err = loadstring(content)
    if not (fn) then
      printerr("loadEnv-5.1 :: Could not load Alfonsfile content: " .. tostring(err))
      os.exit(1)
    end
    setfenv(fn, env)
  elseif "Lua 5.2" == _exp_0 or "Lua 5.3" == _exp_0 or "Lua 5.4" == _exp_0 then
    local err
    fn, err = load(content, "Alfons", "t", env)
    if not (fn) then
      printerr("loadEnv :: Could not load Alfonsfile content: " .. tostring(err))
      os.exit(1)
    end
  end
  return fn
end
return {
  ENVIRONMENT = ENVIRONMENT,
  KEYS = KEYS,
  loadEnv = loadEnv
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.file" ] = function( ... ) local arg = _G.arg;
local printerr
printerr = require("alfons.provide").printerr
local fs = require("filekit")
local readMoon
readMoon = function(file)
  local content
  do
    local _with_0 = fs.safeOpen(file, "r")
    if _with_0.error then
      printerr("loadMoon :: Could not open " .. tostring(file) .. ": " .. tostring(_with_0.error))
      os.exit(1)
    end
    local to_lua
    to_lua = require("moonscript.base").to_lua
    content = to_lua(_with_0:read("*a"))
    if not (content) then
      printerr("loadMoon :: Could not read or parse " .. tostring(file) .. ": " .. tostring(content))
      os.exit(1)
    end
    _with_0:close()
  end
  return content
end
local readLua
readLua = function(file)
  local content
  do
    local _with_0 = fs.safeOpen(file, "r")
    if _with_0.error then
      printerr("readLua :: Could not open " .. tostring(file) .. ": " .. tostring(_with_0.error))
      os.exit(1)
    end
    content = _with_0:read("*a")
    if not (content) then
      printerr("readLua :: Could not read " .. tostring(file) .. ": " .. tostring(content))
      os.exit(1)
    end
    _with_0:close()
  end
  return content
end
return {
  readMoon = readMoon,
  readLua = readLua
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.getopt" ] = function( ... ) local arg = _G.arg;
local getopt
getopt = function(argl)
  local args = {
    commands = { }
  }
  local flags = {
    stop = false,
    command = false,
    wait = false
  }
  local push
  push = function(o, v)
    if flags.command then
      args[flags.command][o] = v
    else
      args[o] = v
    end
  end
  for _index_0 = 1, #argl do
    local _continue_0 = false
    repeat
      local arg = argl[_index_0]
      if arg == "--" then
        flags.stop = true
      end
      if flags.stop then
        table.insert(args, arg)
        _continue_0 = true
        break
      end
      if flags.wait then
        push(flags.wait, arg)
        flags.wait = false
        _continue_0 = true
        break
      end
      if not (arg:match("^%-%-?")) then
        args[arg] = { }
        flags.command = arg
        table.insert(args.commands, arg)
        _continue_0 = true
        break
      end
      do
        local flag = arg:match("^%-(%w)$")
        if flag then
          flags.wait = flag
          _continue_0 = true
          break
        end
      end
      do
        local flagl = arg:match("^%-(%w+)$")
        if flagl then
          for chr in flagl:gmatch(".") do
            push(chr, true)
          end
          _continue_0 = true
          break
        end
      end
      if arg:match("^%-%-?(%w+)=(.+)$") then
        local opt, value = arg:match("^%-%-?(%w+)=(.+)")
        push(opt, value)
        _continue_0 = true
        break
      end
      do
        local opt = arg:match("^%-%-(%w+)$")
        if opt then
          flags.wait = opt
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  if flags.wait then
    push(flags.wait, true)
  end
  return args
end
return {
  getopt = getopt
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.provide" ] = function( ... ) local arg = _G.arg;
local style
style = require("ansikit.style").style
local inotify = require("inotify")
local fs = require("filekit")
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
prints = function(...)
  return print(unpack((function(...)
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = {
      ...
    }
    for _index_0 = 1, #_list_0 do
      local arg = _list_0[_index_0]
      _accum_0[_len_0] = style(arg)
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)(...)))
end
local printError
printError = function(text)
  return print(style("%{red}" .. tostring(text)))
end
local readfile
readfile = function(file)
  do
    local _with_0 = fs.safeOpen(file, "r")
    if _with_0.error then
      error(_with_0.error)
    else
      local contents = _with_0:read("*a")
      _with_0:close()
      return contents
    end
    return _with_0
  end
end
local writefile
writefile = function(file, content)
  do
    local _with_0 = fs.safeOpen(file, "w")
    if _with_0.error then
      error(_with_0.error)
    else
      _with_0:write(content)
      _with_0:close()
    end
    return _with_0
  end
end
local serialize
serialize = function(t)
  local full = "return {\n"
  for k, v in pairs(t) do
    full = full .. "  ['" .. tostring(k) .. "'] = '" .. tostring(v) .. "',"
  end
  full = full .. "}"
  return full
end
local ask
ask = function(str)
  io.write(style(str))
  return io.read()
end
local env = setmetatable({ }, {
  __index = function(self, i)
    return os.getenv(i)
  end
})
local cmd = os.execute
local sh = cmd
local cmdfail
cmdfail = function(str)
  local code = cmd(str)
  if not (code == 0) then
    return os.exit(code)
  end
end
local shfail = cmdfail
local basename
basename = function(file)
  return file:match("(.+)%..+")
end
local filename
filename = function(file)
  return file:match(".+/(.+)%..+")
end
local extension
extension = function(file)
  return file:match(".+%.(.+)")
end
local pathname
pathname = function(file)
  return file:match("(.+/).+")
end
local isAbsolute
isAbsolute = function(path)
  return path:match("^/")
end
local wildcard = fs.iglob
local iwildcard
iwildcard = function(paths)
  local all = { }
  for _index_0 = 1, #paths do
    local path = paths[_index_0]
    for globbed in fs.iglob(path) do
      table.insert(all, globbed)
    end
  end
  local i, n = 0, #all
  return function()
    i = i + 1
    if i <= n then
      return all[i]
    end
  end
end
local glob
glob = function(glob)
  return function(file)
    return fs.matchGlob((fs.fromGlob(glob)), file)
  end
end
local build
build = function(iter, fn)
  local times = { }
  if fs.exists(".alfons") then
    prints("%{cyan}:%{white} using .alfons")
    times = dofile(".alfons")
    do
      local _tbl_0 = { }
      for k, v in pairs(times) do
        _tbl_0[k] = tonumber(v)
      end
      times = _tbl_0
    end
  end
  for file in iter do
    local mtime = fs.getLastModification(file)
    if times[file] then
      if mtime > times[file] then
        fn(file)
      end
      times[file] = mtime
    else
      fn(file)
      times[file] = mtime
    end
  end
  return writefile(".alfons", serialize(times))
end
local EVENTS = {
  access = "IN_ACCESS",
  change = "IN_ATTRIB",
  write = "IN_CLOSE_WRITE",
  shut = "IN_CLOSE_NOWRITE",
  close = "IN_CLOSE",
  create = "IN_CREATE",
  delete = "IN_DELETE",
  destruct = "IN_DELETE_SELF",
  modify = "IN_MODIFY",
  migrate = "IN_MOVE_SELF",
  move = "IN_MOVE",
  movein = "IN_MOVED_TO",
  moveout = "IN_MOVED_FROM",
  open = "IN_OPEN",
  all = "IN_ALL_EVENTS"
}
local bit_band
bit_band = function(a, b)
  local result, bitval = 0, 1
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then
      result = result + bitval
    end
    bitval = bitval * 2
    a = math.floor(a / 2)
    b = math.floor(b / 2)
  end
  return result
end
local watch
watch = function(dirs, exclude, evf, pred, fn)
  local handle = inotify.init()
  if evf == "live" then
    evf = {
      "write",
      "movein"
    }
  end
  local cdir = fs.currentDir()
  for i, dir in ipairs(dirs) do
    if not (isAbsolute(dir)) then
      dirs[i] = fs.reduce(fs.combine(cdir, dir))
    end
  end
  for i, dir in ipairs(exclude) do
    if not (isAbsolute(dir)) then
      exclude[i] = fs.reduce(fs.combine(cdir, dir))
    end
  end
  for i, dir in ipairs(dirs) do
    for ii, subdir in ipairs(fs.listAll(dir)) do
      local _continue_0 = false
      repeat
        local br8k = false
        for _index_0 = 1, #exclude do
          local exclusion = exclude[_index_0]
          if subdir:match("^" .. tostring(exclusion)) then
            br8k = true
          end
        end
        if br8k then
          _continue_0 = true
          break
        end
        if fs.isDir(subdir) then
          table.insert(dirs, subdir)
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  prints("%{cyan}:%{white} Watching for:")
  for _index_0 = 1, #dirs do
    local dir = dirs[_index_0]
    prints("  - %{green}" .. tostring(dir))
  end
  local events
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #evf do
      local ev = evf[_index_0]
      _accum_0[_len_0] = inotify[EVENTS[ev]]
      _len_0 = _len_0 + 1
    end
    events = _accum_0
  end
  local uevf
  do
    local _tbl_0 = { }
    for k, v in pairs(evf) do
      _tbl_0[k] = v
    end
    uevf = _tbl_0
  end
  if not (contains(evf, "create")) then
    table.insert(evf, "create")
    table.insert(events, inotify.IN_CREATE)
  end
  local watchers = { }
  for _index_0 = 1, #dirs do
    local dir = dirs[_index_0]
    watchers[dir] = handle:addwatch(dir, unpack(events))
  end
  local reversed
  do
    local _tbl_0 = { }
    for k, v in pairs(watchers) do
      _tbl_0[v] = k
    end
    reversed = _tbl_0
  end
  while true do
    local evts = handle:read()
    if not (evts) then
      break
    end
    for _index_0 = 1, #evts do
      local _continue_0 = false
      repeat
        local ev = evts[_index_0]
        local full = fs.combine(reversed[ev.wd], (ev.name or ""))
        if (fs.isDir(full)) and (bit_band(ev.mask, inotify.IN_CREATE)) and not watchers[dir] then
          prints("%{cyan}:%{white} Added to watchlist: %{green}" .. tostring(full))
          watchers[full] = handle:addwatch(full, unpack(events))
          reversed[watchers[full]] = full
        end
        local actions = { }
        for action, evt in pairs(EVENTS) do
          local _continue_0 = false
          repeat
            if action == "all" then
              _continue_0 = true
              break
            end
            if 0 ~= bit_band(ev.mask, inotify[evt]) then
              if contains(uevf, action) then
                table.insert(actions, action)
              end
            end
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        if #actions == 0 then
          _continue_0 = true
          break
        end
        if not (pred(full, actions)) then
          _continue_0 = true
          break
        end
        prints("%{cyan}:%{white} Triggered %{magenta}" .. tostring(table.concat(actions, ', ')) .. "%{white}: %{yellow}" .. tostring(full))
        fn(full, actions)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  return handle:close()
end
return {
  contains = contains,
  prints = prints,
  printError = printError,
  readfile = readfile,
  writefile = writefile,
  serialize = serialize,
  cmd = cmd,
  cmdfail = cmdfail,
  sh = sh,
  shfail = shfail,
  wildcard = wildcard,
  iwildcard = iwildcard,
  glob = glob,
  basename = basename,
  filename = filename,
  extension = extension,
  pathname = pathname,
  build = build,
  watch = watch,
  env = env,
  ask = ask
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.version" ] = function( ... ) local arg = _G.arg;
return {
  VERSION = "4.0"
}

end
end

end

local VERSION
VERSION = require("alfons.version").VERSION
local prints
prints = require("alfons.provide").prints
local setfenv
setfenv = require("alfons.compat").setfenv
local fs = require("filekit")
prints("%{bold blue}Alfons " .. tostring(VERSION))
local getopt
getopt = require("alfons.getopt").getopt
local inspect = require("inspect")
local args = getopt({
  ...
})
local FILE
do
  if args.f then
    FILE = args.f
  elseif args.file then
    FILE = args.file
  elseif fs.exists("Alfons.lua") then
    FILE = "Alfons.lua"
  elseif fs.exists("Alfons.moon") then
    FILE = "Alfons.moon"
  else
    FILE = error("No Alfonsfile found.")
  end
end
local LANGUAGE
do
  if FILE:match("moon$") then
    LANGUAGE = "moon"
  elseif FILE:match("lua$") then
    LANGUAGE = "lua"
  elseif args.type then
    LANGUAGE = args.type
  else
    LANGUAGE = error("Cannot resolve format for Alfonsfile.")
  end
end
print("Using " .. tostring(FILE) .. " (" .. tostring(LANGUAGE) .. ")")
local readMoon, readLua
do
  local _obj_0 = require("alfons.file")
  readMoon, readLua = _obj_0.readMoon, _obj_0.readLua
end
local ENVIRONMENT, KEYS, loadEnv
do
  local _obj_0 = require("alfons.env")
  ENVIRONMENT, KEYS, loadEnv = _obj_0.ENVIRONMENT, _obj_0.KEYS, _obj_0.loadEnv
end
local content
local _exp_0 = LANGUAGE
if "moon" == _exp_0 then
  content = readMoon(FILE)
elseif "lua" == _exp_0 then
  content = readLua(FILE)
else
  content = error("Cannot resolve format '" .. tostring(LANGUAGE) .. "' for Alfonsfile.")
end
local environment
do
  local _tbl_0 = { }
  for k, v in pairs(ENVIRONMENT) do
    _tbl_0[k] = v
  end
  environment = _tbl_0
end
environment.args = args
local alfons = loadEnv(content, environment)
local list = alfons(args)
local tasks
if list then
  tasks = list.tasks
else
  local contains
  contains = require("alfons.provide").contains
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
for tname, ttask in pairs(tasks) do
  if "function" ~= type(ttask) then
    printerr("alfons :: Task '" .. tostring(nname) .. "' is not a function")
    os.exit(1)
  end
end
local tasks_run = 0
local run
run = function(name, task, argl)
  tasks_run = tasks_run + 1
  local self
  do
    local _tbl_0 = { }
    for k, v in pairs(argl) do
      _tbl_0[k] = v
    end
    self = _tbl_0
  end
  self.name = name
  self.task = function()
    return run(name, task, argl)
  end
  return task(self)
end
do
  local _tbl_0 = { }
  for k, v in pairs(tasks) do
    _tbl_0[k] = (function(...)
      return run(k, v, {
        ...
      })
    end)
  end
  environment.tasks = _tbl_0
end
environment.load = function(mod)
  local loadtasks = require("alfons.tasks." .. tostring(mod))
  for tname, ttask in pairs(loadtasks.tasks) do
    if "function" == type(ttask) then
      setfenv(ttask, environment)
      tasks[tname] = ttask
      environment.tasks[tname] = function(...)
        return run(tname, ttask, {
          ...
        })
      end
    end
  end
end
if tasks.always then
  prints("%{green}->%{white} always")
  run("always", tasks.always, args.always or { })
end
local _list_0 = args.commands
for _index_0 = 1, #_list_0 do
  local command = _list_0[_index_0]
  if tasks[command] then
    prints("%{green}->%{white} " .. tostring(command))
    run(command, tasks[command], args[command] or { })
    if tasks.teardown then
      run("teardown", tasks.teardown, args.teardown or { })
    end
  end
end
if tasks.default and tasks_run == 0 then
  prints("%{green}->%{white} default")
  return run("default", tasks.default, args.default)
end
