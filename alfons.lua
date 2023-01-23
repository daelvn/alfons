do
local _ENV = _ENV
package.preload[ "alfons.env" ] = function( ... ) local arg = _G.arg;
local style
style = require("ansikit.style").style
local setfenv = setfenv or require("alfons.setfenv")
local path = require("path")
local fs = fs or require("path.fs")
local env = require("path.env")
local fsinfo = require("path.info")
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
  fs = fs,
  path = path,
  env = env,
  fsinfo = fsinfo
}
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
local safeOpen
safeOpen = function(path, mode)
  local a, b = io.open(path, mode)
  return a and a or {
    error = b
  }
end
local readMoon
readMoon = function(file)
  local content
  do
    local _with_0 = safeOpen(file, "r")
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
    local _with_0 = safeOpen(file, "r")
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
local readTeal
readTeal = function(file)
  local content
  do
    local _with_0 = safeOpen(file, "r")
    if _with_0.error then
      return nil, "Could not open " .. tostring(file) .. ": " .. tostring(_with_0.error)
    end
    local init_env, gen
    do
      local _obj_0 = require("tl")
      init_env, gen = _obj_0.init_env, _obj_0.gen
    end
    local gwe = init_env(true, false)
    content = gen((_with_0:read("*a")), gwe)
    if not (content) then
      return nil, "Could not read " .. tostring(file) .. ": " .. tostring(content)
    end
    _with_0:close()
  end
  return content
end
return {
  readMoon = readMoon,
  readLua = readLua,
  readTeal = readTeal
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
local sanitize, PREFIX, initEnv, runString
sanitize = function(pattern)
  if pattern then
    return pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
  end
end
PREFIX = "test.alfons."
initEnv = function(run, base, genv, modname, pretty)
  if base == nil then
    base = ENVIRONMENT
  end
  if modname == nil then
    modname = "main"
  end
  if pretty == nil then
    pretty = false
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
    return (rawget(self, k)) or (function()
      for scope, t in pairs(genv) do
        for name, task in pairs(t.tasks) do
          if k == name then
            return task
          end
        end
      end
      if pretty then
        provide.printError("Task '" .. tostring(k) .. "' does not exist.")
        return os.exit(1)
      else
        return error("Task '" .. tostring(k) .. "' does not exist.")
      end
    end)()
  end
  envmt.__ran = 0
  return env
end
runString = function(content, environment, runAlways, child, genv, rqueue, pretty)
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
  if pretty == nil then
    pretty = false
  end
  if not ("string" == type(content)) then
    return nil, "Taskfile content must be a string"
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
    modname = "main"
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
    local callstack = (getmetatable(genv)).store.callstack
    table.insert(callstack, name)
    local ret = task(self)
    table.remove(callstack, #callstack)
    return ret
  end
  if not (getmetatable(genv)) then
    setmetatable(genv, {
      store = {
        callstack = { }
      }
    })
  end
  local env = initEnv(run, environment, genv, modname, pretty)
  genv[modname] = env
  local alf, alfErr = loadEnv(content, env)
  if alfErr then
    return nil, "Could not load Taskfile " .. tostring(child) .. ": " .. tostring(alfErr)
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
    rawset(env, "exists", function(wants)
      for scope, t in pairs(genv) do
        for name, task in pairs(t.tasks) do
          if wants == name then
            return true
          end
        end
      end
      return false
    end)
    rawset(env, "calls", function(cmdmd)
      local callstack = (getmetatable(genv)).store.callstack
      local current = callstack[#callstack]
      local on = false
      local subcommands = { }
      local i = 0
      local _list_0 = args.commands
      for _index_0 = 1, #_list_0 do
        local cmd = _list_0[_index_0]
        i = i + 1
        if on then
          if rawget(env.tasks, cmd) then
            break
          end
          subcommands[#subcommands + 1] = cmd
          args.commands[i] = nil
        else
          if cmd == current then
            on = true
          end
        end
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i, e in provide.npairs(args.commands) do
          _accum_0[_len_0] = e
          _len_0 = _len_0 + 1
        end
        args.commands = _accum_0
      end
      return subcommands
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
          if pretty then
            provide.printError("Task '" .. tostring(k) .. "' does not exist.")
            return os.exit(1)
          else
            return error("Task '" .. tostring(k) .. "' does not exist.")
          end
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
          if pretty then
            provide.printError("Task '" .. tostring(k) .. "' does not exist.")
            return os.exit(1)
          else
            return error("Task '" .. tostring(k) .. "' does not exist.")
          end
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
local Path = require("path")
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
      if Path.exists(pt) then
        file = pt
      end
    end
    for _index_0 = 1, #moonpaths do
      local path = moonpaths[_index_0]
      local pt = path:gsub(swildcard, mod)
      if Path.exists(pt) then
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
local listAll, glob, iglob
do
  local _obj_0 = require("alfons.wildcard")
  listAll, glob, iglob = _obj_0.listAll, _obj_0.glob, _obj_0.iglob
end
local Path = require("path")
local fs = require("path.fs")
local unpack = unpack or table.unpack
local printerr
printerr = function(t)
  return io.stderr:write(t .. "\n")
end
local inotify
do
  local ok
  ok, inotify = pcall(function()
    return require("inotify")
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
  return printerr(unpack((function(...)
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
  return printerr(style("%{red}" .. tostring(text)))
end
local safeOpen
safeOpen = function(path, mode)
  local a, b = io.open(path, mode)
  return a and a or {
    error = b
  }
end
local readfile
readfile = function(file)
  do
    local _with_0 = safeOpen(file, "r")
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
    local _with_0 = safeOpen(file, "w")
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
local filename = Path.stem
local extension = Path.suffix
local pathname = Path.parent
local isAbsolute
isAbsolute = function(path)
  return path:match("^/")
end
local wildcard = iglob
local iwildcard
iwildcard = function(paths)
  local all = { }
  for _index_0 = 1, #paths do
    local path = paths[_index_0]
    for globbed in iglob(path) do
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
local isEmpty
isEmpty = function(path)
  if not (Path.isdir(path)) then
    return false
  end
  return 0 == #(listAll(path))
end
local delete
delete = function(loc)
  if not (Path.exists(loc)) then
    return 
  end
  if Path.isfile(loc or isEmpty(loc)) then
    return fs.remove(loc)
  else
    for node in fs.dir(loc) do
      local _continue_0 = false
      repeat
        if node:match("%.%.") then
          _continue_0 = true
          break
        end
        delete(node)
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    return fs.remove(loc)
  end
end
local copy
copy = function(fr, to)
  if not (Path.exists(fr)) then
    error("copy $ " .. tostring(fr) .. " does not exist")
  end
  if Path.isdir(fr) then
    if Path.exists(to) then
      error("copy $ " .. tostring(to) .. " already exists")
    end
    fs.mkdir(to)
    for node in fs.dir(fr) do
      copy(node, (Path(to, (Path.name(node)))))
    end
  elseif Path.isfile(fr) then
    return fs.copy(fr, to)
  end
end
local build
build = function(iter, fn)
  local times = { }
  if Path.exists(".alfons") then
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
    local mtime = fs.mtime(file)
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
  local cdir = Path.cwd()
  for i, dir in ipairs(dirs) do
    if not (isAbsolute(dir)) then
      dirs[i] = Path(cdir, dir)
    end
  end
  for i, dir in ipairs(exclude) do
    if not (isAbsolute(dir)) then
      exclude[i] = Path(cdir, dir)
    end
  end
  for i, dir in ipairs(dirs) do
    for ii, subdir in ipairs(listAll(dir)) do
      local _continue_0 = false
      repeat
        local doBreak = false
        for _index_0 = 1, #exclude do
          local exclusion = exclude[_index_0]
          if subdir:match("^" .. tostring(exclusion)) then
            doBreak = true
          end
        end
        if doBreak then
          _continue_0 = true
          break
        end
        if Path.isdir(subdir) then
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
        local full = Path(reversed[ev.wd], (ev.name or ""))
        if (Path.isdir(full)) and (bit_band(ev.mask, inotify.IN_CREATE)) and not watchers[full] then
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
local npairs
npairs = function(t)
  local keys
  do
    local _accum_0 = { }
    local _len_0 = 1
    for k, v in pairs(t) do
      if "number" == type(k) then
        _accum_0[_len_0] = k
        _len_0 = _len_0 + 1
      end
    end
    keys = _accum_0
  end
  table.sort(keys)
  local i = 0
  local n = #keys
  return function()
    i = i + 1
    if i <= n then
      return keys[i], t[keys[i]]
    end
  end
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
  show = show,
  npairs = npairs,
  listAll = listAll,
  safeOpen = safeOpen,
  isEmpty = isEmpty,
  delete = delete,
  copy = copy
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
package.preload[ "alfons.tasks.fetch" ] = function( ... ) local arg = _G.arg;
return {
  tasks = {
    fetch = function(self)
      local http = require("http.request")
      local headers, stream = assert((http.new_from_uri(self.url)):go())
      local body = assert(stream:get_body_as_string())
      if "200" ~= headers:get(":status") then
        return error(body)
      else
        return body
      end
    end
  }
}
end
end

do
local _ENV = _ENV
package.preload[ "alfons.tasks.teal" ] = function( ... ) local arg = _G.arg;
return {
  tasks = {
    always = function(self)
      load("fetch")
      if not (store.teal_auto == true) then
        tasks.install()
        return tasks.typings({
          modules = store.typings
        })
      end
    end,
    install = function(self)
      if exists("teal_preinstall") then
        prints("%{cyan}Teal:%{white} Running pre-install hook.")
        tasks.teal_preinstall()
      end
      prints("%{cyan}Teal:%{white} Installing dependencies.")
      local _list_0 = store.dependencies
      for _index_0 = 1, #_list_0 do
        local dep = _list_0[_index_0]
        prints("%{green}+ " .. tostring(dep))
        sh("luarocks install " .. tostring(dep))
      end
      if exists("teal_postinstall") then
        prints("%{cyan}Teal:%{white} Running post-install hook.")
        return tasks.teal_postinstall()
      end
    end,
    build = function(self)
      if exists("teal_prebuild") then
        prints("%{cyan}Teal:%{white} Running pre-build hook.")
        tasks.teal_prebuild()
      end
      prints("%{cyan}Teal:%{white} Building project.")
      sh("tl build")
      if exists("teal_postbuild") then
        prints("%{cyan}Teal:%{white} Running post-build hook.")
        return tasks.teal_postbuild()
      end
    end,
    typings = function(self)
      local json = require("dkjson")
      local fetchdefs
      fetchdefs = function(mod)
        prints("%{cyan}Teal:%{white} Fetching type definitions for " .. tostring(mod) .. ".")
        local unjson = tasks.fetch({
          url = "https://api.github.com/repos/teal-language/teal-types/contents/types/" .. tostring(mod)
        })
        local files = json.decode(unjson)
        for _index_0 = 1, #files do
          local _continue_0 = false
          repeat
            local file = files[_index_0]
            if not (file.type == "file") then
              _continue_0 = true
              break
            end
            local name = file.name
            local def = tasks.fetch({
              url = "https://raw.githubusercontent.com/teal-language/teal-types/master/types/" .. tostring(mod) .. "/" .. tostring(name)
            })
            writefile(name, def)
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      end
      local mod = self.m or self.module
      local mods = self.modules
      if mod then
        return fetchdefs(mod)
      elseif mods then
        local _list_0 = mods
        for _index_0 = 1, #_list_0 do
          local md = _list_0[_index_0]
          fetchdefs(md)
        end
      end
    end
  }
}
end
end

do
local _ENV = _ENV
package.preload[ "alfons.version" ] = function( ... ) local arg = _G.arg;
return {
  VERSION = "5.0.0"
}
end
end

do
local _ENV = _ENV
package.preload[ "alfons.wildcard" ] = function( ... ) local arg = _G.arg;
local Path = require("path")
local fs = require("path.fs")
local listAll
listAll = function(dir)
  local _accum_0 = { }
  local _len_0 = 1
  for node in fs.scandir(dir) do
    _accum_0[_len_0] = node
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
local fromGlob
fromGlob = function(glob)
  local sanitize
  sanitize = function(pattern)
    if pattern then
      return pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
    end
  end
  local saglob = sanitize(glob)
  do
    local _with_0 = saglob
    local mid = _with_0:gsub("%%%*%%%*", ".*")
    mid = mid:gsub("%%%*", "[^/]*")
    mid = mid:gsub("%%%?", ".")
    return tostring(mid) .. "$"
  end
end
local matchGlob
matchGlob = function(glob, path)
  return nil ~= path:match(glob)
end
local glob
glob = function(path, all)
  if all == nil then
    all = { }
  end
  if not (path:match("%*")) then
    return path
  end
  local currentpath = "."
  local fullpath = path
  local correctpath = ""
  for i = 1, #fullpath do
    if (fullpath:sub(i, i)) == (currentpath:sub(i, i)) then
      correctpath = correctpath .. currentpath:sub(i, i)
    end
  end
  local toglob = fromGlob(fullpath)
  local _list_0 = listAll(correctpath)
  for _index_0 = 1, #_list_0 do
    local node = _list_0[_index_0]
    if node:match(toglob) then
      table.insert(all, node)
    end
  end
  return all
end
local iglob
iglob = function(path)
  local globbed = glob(path)
  local i = 0
  local n = #globbed
  return function()
    i = i + 1
    if i <= n then
      return globbed[i]
    end
  end
end
return {
  listAll = listAll,
  fromGlob = fromGlob,
  matchGlob = matchGlob,
  glob = glob,
  iglob = iglob
}
end
end

local VERSION
VERSION = require("alfons.version").VERSION
local style
style = require("ansikit.style").style
local Path = require("path")
local unpack = unpack or table.unpack
local printerr
printerr = function(t)
  return io.stderr:write(t .. "\n")
end
local prints
prints = function(...)
  return printerr(unpack((function(...)
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
  return printerr(style("%{red}" .. tostring(text)))
end
local errors
errors = function(code, msg)
  printerr(style("%{red}" .. tostring(msg)))
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
  elseif Path.exists("Alfons.lua") then
    FILE = "Alfons.lua"
  elseif Path.exists("Alfons.moon") then
    FILE = "Alfons.moon"
  elseif Path.exists("Alfons.tl") then
    FILE = "Alfons.tl"
  else
    FILE = errors(1, "No Taskfile found.")
  end
end
local LANGUAGE
do
  if FILE:match("moon$") then
    LANGUAGE = "moon"
  elseif FILE:match("lua$") then
    LANGUAGE = "lua"
  elseif FILE:match("tl$") then
    LANGUAGE = "teal"
  elseif args.type then
    LANGUAGE = args.type
  else
    LANGUAGE = errors(1, "Cannot resolve format for Taskfile.")
  end
end
printerr("Using " .. tostring(FILE) .. " (" .. tostring(LANGUAGE) .. ")")
local readMoon, readLua, readTeal
do
  local _obj_0 = require("alfons.file")
  readMoon, readLua, readTeal = _obj_0.readMoon, _obj_0.readLua, _obj_0.readTeal
end
local content, contentErr
local _exp_0 = LANGUAGE
if "moon" == _exp_0 then
  content, contentErr = readMoon(FILE)
elseif "lua" == _exp_0 then
  content, contentErr = readLua(FILE)
elseif "teal" == _exp_0 then
  content, contentErr = readTeal(FILE)
else
  content, contentErr = errors(1, "Cannot resolve format '" .. tostring(LANGUAGE) .. "' for Taskfile.")
end
if not (content) then
  errors(1, contentErr)
end
local runString
runString = require("alfons.init").runString
local alfons, alfonsErr = runString(content, nil, true, 0, { }, { }, true)
if not (alfons) then
  errors(1, alfonsErr)
end
local env = alfons(...)
local _list_0 = args.commands
for _index_0 = 1, #_list_0 do
  local command = _list_0[_index_0]
  env.tasks[command](args[command])
  if rawget(env.tasks, "teardown") then
    local _ = (rawget(env.tasks, "teardown"))
  end
end
return env.finalize()
