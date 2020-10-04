do

do
local _ENV = _ENV
package.preload[ "alfons.env" ] = function( ... ) local arg = _G.arg;
local style
style = require("ansikit.style").style
local setfenv = setfenv or require("alfons.setfenv")
local fs = require("filekit")
local provide = require("alfons.provide")
local unpack = unpack or table.unpack
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
local loadEnv
loadEnv = function(content, env)
  local fn
  local _exp_0 = _VERSION
  if "Lua 5.1" == _exp_0 then
    local err
    fn, err = loadstring(content)
    if not (fn) then
      return nil, "Could not load Alfonsfile content (5.1): " .. tostring(err)
    end
    setfenv(fn, env)
  elseif "Lua 5.2" == _exp_0 or "Lua 5.3" == _exp_0 or "Lua 5.4" == _exp_0 then
    local err
    fn, err = load(content, "Alfons", "t", env)
    if not (fn) then
      return nil, "Could not load Alfonsfile content (5.2+): " .. tostring(err)
    end
  end
  return fn
end
return {
  ENVIRONMENT = ENVIRONMENT,
  loadEnv = loadEnv
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.file" ] = function( ... ) local arg = _G.arg;
local fs = require("filekit")
local readMoon
readMoon = function(file)
  local content
  do
    local _with_0 = fs.safeOpen(file, "r")
    if _with_0.error then
      return nil, "Could not open " .. tostring(file) .. ": " .. tostring(_with_0.error)
    end
    local to_lua
    to_lua = require("moonscript.base").to_lua
    local err
    content, err = to_lua(_with_0:read("*a"))
    if not (content) then
      return nil, "Could not read or parse " .. tostring(file) .. ": " .. tostring(err)
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
      return nil, "Could not open " .. tostring(file) .. ": " .. tostring(_with_0.error)
    end
    content = _with_0:read("*a")
    if not (content) then
      return nil, "Could not read " .. tostring(file) .. ": " .. tostring(content)
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
package.preload[ "alfons.init" ] = function( ... ) local arg = _G.arg;
local ENVIRONMENT, loadEnv
do
  local _obj_0 = require("alfons.env")
  ENVIRONMENT, loadEnv = _obj_0.ENVIRONMENT, _obj_0.loadEnv
end
local getopt
getopt = require("alfons.getopt").getopt
local look
look = require("alfons.look").look
local provide = require("alfons.provide")
local unpack = unpack or table.unpack
local inspect = require("inspect")
local sanitize, PREFIX, initEnv, runString
sanitize = function(pattern)
  if pattern then
    return pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
  end
end
PREFIX = "test.alfons."
initEnv = function(run, base, genv, modname)
  if base == nil then
    base = ENVIRONMENT
  end
  if modname == nil then
    modname = "__main__"
  end
  local env, envmt = { }, { }
  local tasksmt
  env.tasks, tasksmt = { }, { }
  setmetatable(env, envmt)
  setmetatable(env.tasks, tasksmt)
  envmt.__index = function(self, k)
    if genv and k == "__ran" then
      return (getmetatable(genv[modname])).__ran
    elseif genv and k == "store" then
      return (getmetatable(genv)).store
    else
      return base[k] or provide[k]
    end
  end
  envmt.__newindex = function(self, k, v)
    if "function" ~= type(v) then
      error("Task '" .. tostring(k) .. "' is not a function.")
    end
    self.tasks[k] = function(t)
      if t == nil then
        t = { }
      end
      return run(k, v, t)
    end
  end
  tasksmt.__index = function(self, k)
    return error("Task '" .. tostring(k) .. "' does not exist.")
  end
  envmt.__ran = 0
  return env
end
runString = function(content, environment, runAlways, child, genv, rqueue)
  if environment == nil then
    environment = ENVIRONMENT
  end
  if runAlways == nil then
    runAlways = true
  end
  if child == nil then
    child = 0
  end
  if genv == nil then
    genv = { }
  end
  if rqueue == nil then
    rqueue = { }
  end
  if not ("string" == type(content)) then
    error("Taskfile content must be a string")
  end
  local modname
  if (not content:match("\n")) and (content:match("^" .. tostring(sanitize(PREFIX)))) then
    modname = content
    local contentErr
    content, contentErr = look(content)
    if contentErr then
      return nil, contentErr
    end
  else
    modname = "__main__"
  end
  if genv[modname] then
    return genv[modname]
  end
  local run
  run = function(name, task, argl)
    (getmetatable(genv[modname])).__ran = (getmetatable(genv[modname])).__ran + 1
    local self = setmetatable({ }, {
      __index = argl
    })
    self.name = name
    self.task = function()
      return run(name, task, argl)
    end
    return task(self)
  end
  if not (getmetatable(genv)) then
    setmetatable(genv, {
      store = { }
    })
  end
  local env = initEnv(run, environment, genv, modname)
  genv[modname] = env
  local alf, alfErr = loadEnv(content, env)
  if alfErr then
    return nil, "Could not run Taskfile " .. tostring(child) .. ": " .. tostring(alfErr)
  end
  return function(...)
    local argl = {
      ...
    }
    local args = getopt(argl)
    rawset(env, "args", args)
    rawset(env, "uses", function(cmdmd)
      return provide.contains((args.commands or { }), cmdmd)
    end)
    local list = alf(args)
    local tasks = list and (list.tasks and list.tasks or { }) or { }
    for k, v in pairs(tasks) do
      env.tasks[k] = function(t)
        if t == nil then
          t = { }
        end
        return run(k, v, t)
      end
    end
    do
      local fintask = (rawget(env.tasks, "finalize"))
      if fintask then
        rqueue[#rqueue + 1] = fintask
      end
    end
    rawset(env, "load", function(mod)
      mod = PREFIX .. mod
      if genv[mod] then
        return genv[mod]
      end
      local subalf, subalfErr = runString(mod, env, runAlways, child + 1, genv, rqueue)
      if subalfErr then
        error(subalfErr)
      end
      local subenv = subalf(unpack(argl))
      local tasksmt = getmetatable(env.tasks)
      tasksmt.__index = function(self, k)
        return (rawget(self, k)) or (function()
          for scope, t in pairs(genv) do
            for name, task in pairs(t.tasks) do
              if k == name then
                return task
              end
            end
          end
          return error("Task '" .. tostring(k) .. "' does not exist.")
        end)()
      end
      local subtasksmt = getmetatable(subenv.tasks)
      subtasksmt.__index = function(self, k)
        return (rawget(self, k)) or (function()
          for scope, t in pairs(genv) do
            for name, task in pairs(t.tasks) do
              if k == name then
                return task
              end
            end
          end
          return error("Task '" .. tostring(k) .. "' does not exist.")
        end)()
      end
    end)
    if runAlways and (rawget(env.tasks, "always")) then
      (rawget(env.tasks, "always"))();
      (getmetatable(genv[modname])).__ran = (getmetatable(genv[modname])).__ran - 1
    end
    rawset(env, "finalize", function()
      for scope, t in pairs(genv) do
        if (rawget(t.tasks, "default")) and t.__ran < 1 then
          (rawget(t.tasks, "default"))()
        end
      end
      for i = #rqueue, 1, -1 do
        rqueue[i]()
      end
    end)
    return env
  end
end
return {
  runString = runString,
  initEnv = initEnv
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.look" ] = function( ... ) local arg = _G.arg;
local readMoon, readLua
do
  local _obj_0 = require("alfons.file")
  readMoon, readLua = _obj_0.readMoon, _obj_0.readLua
end
local fs = require("filekit")
local sanitize
sanitize = function(pattern)
  if pattern == nil then
    pattern = ""
  end
  return pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
end
local dirsep, pathsep, wildcard = package.config:match("^(.)\n(.)\n(.)")
local modsep = "%."
local swildcard = sanitize(wildcard)
local makeLook
makeLook = function(gpath)
  if gpath == nil then
    gpath = package.path
  end
  local paths
  do
    local _accum_0 = { }
    local _len_0 = 1
    for path in gpath:gmatch("[^" .. tostring(pathsep) .. "]+") do
      _accum_0[_len_0] = path
      _len_0 = _len_0 + 1
    end
    paths = _accum_0
  end
  local moonpaths
  do
    local _accum_0 = { }
    local _len_0 = 1
    for path in gpath:gmatch("[^" .. tostring(pathsep) .. "]+") do
      _accum_0[_len_0] = path:gsub("%.lua$", ".moon")
      _len_0 = _len_0 + 1
    end
    moonpaths = _accum_0
  end
  return function(name)
    local mod = name:gsub(modsep, dirsep)
    local file = false
    for _index_0 = 1, #paths do
      local path = paths[_index_0]
      local pt = path:gsub(swildcard, mod)
      if fs.exists(pt) then
        file = pt
      end
    end
    for _index_0 = 1, #moonpaths do
      local path = moonpaths[_index_0]
      local pt = path:gsub(swildcard, mod)
      if fs.exists(pt) then
        file = pt
      end
    end
    if file then
      local read = (file:match("%.lua$")) and readLua or readMoon
      local content, contentErr = read(file)
      if content then
        return content
      else
        return nil, contentErr
      end
    else
      return nil, tostring(name) .. " not found."
    end
  end
end
return {
  makeLook = makeLook,
  look = makeLook()
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.provide" ] = function( ... ) local arg = _G.arg;
local style
style = require("ansikit.style").style
local fs = require("filekit")
local unpack = unpack or table.unpack
local inotify
do
  local ok
  ok, inotify = pcall(function()
    return require("intoify")
  end)
  inotify = ok and inotify or nil
end
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
local show
show = function(str)
  return prints("%{cyan}:%{white} " .. tostring(str))
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
  return function(path)
    return fs.matchGlob((fs.fromGlob(glob)), path)
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
  if not (inotify) then
    error("Could not load inotify")
  end
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
        if (fs.isDir(full)) and (bit_band(ev.mask, inotify.IN_CREATE)) and not watchers[full] then
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
  ask = ask,
  show = show
}

end
end

do
local _ENV = _ENV
package.preload[ "alfons.setfenv" ] = function( ... ) local arg = _G.arg;
return setfenv or function(fn, env)
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

end
end

do
local _ENV = _ENV
package.preload[ "alfons.version" ] = function( ... ) local arg = _G.arg;
return {
  VERSION = "4.2"
}

end
end

end

local VERSION
VERSION = require("alfons.version").VERSION
local style
style = require("ansikit.style").style
local fs = require("filekit")
local unpack = unpack or table.unpack
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
local errors
errors = function(code, msg)
  print(style("%{red}" .. tostring(msg)))
  return os.exit(code)
end
prints("%{bold blue}Alfons " .. tostring(VERSION))
local getopt
getopt = require("alfons.getopt").getopt
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
    FILE = errors(1, "No Alfonsfile found.")
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
    LANGUAGE = errors(1, "Cannot resolve format for Alfonsfile.")
  end
end
print("Using " .. tostring(FILE) .. " (" .. tostring(LANGUAGE) .. ")")
local readMoon, readLua
do
  local _obj_0 = require("alfons.file")
  readMoon, readLua = _obj_0.readMoon, _obj_0.readLua
end
local content, contentErr
local _exp_0 = LANGUAGE
if "moon" == _exp_0 then
  content, contentErr = readMoon(FILE)
elseif "lua" == _exp_0 then
  content, contentErr = readLua(FILE)
else
  content, contentErr = errors(1, "Cannot resolve format '" .. tostring(LANGUAGE) .. "' for Alfonsfile.")
end
if not (content) then
  errors(1, contentErr)
end
local runString
runString = require("alfons.init").runString
local alfons, alfonsErr = runString(content)
if not (alfons) then
  errors(1, alfonsErr)
end
local env = alfons(...)
local _list_0 = args.commands
for _index_0 = 1, #_list_0 do
  local command = _list_0[_index_0]
  if env.tasks[command] then
    env.tasks[command](args[command])
  end
  if rawget(env.tasks, "teardown") then
    local _ = (rawget(env.tasks, "teardown"))
  end
end
return env.finalize()
