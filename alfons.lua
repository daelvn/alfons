local ltext = require("ltext")
local file = require("file")
local ms
if not pcall(function()
  ms = require("moonscript.base")
end) then
  ms = false
end
print(ltext.title("alfons 14.11.2018"))
local gen_env
gen_env = function()
  return {
    ltext = ltext,
    file = file,
    coroutine = coroutine,
    table = table,
    utf8 = utf8,
    io = io,
    os = os,
    string = string,
    math = math,
    assert = assert,
    error = error,
    pcall = pcall,
    dofile = dofile,
    load = load,
    loadfile = loadfile,
    require = require,
    next = next,
    ipairs = ipairs,
    pairs = pairs,
    ipairs = ipairs,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    print = print
  }
end
local files = {
  "Alfons",
  "alfons",
  "Alfons.moon",
  "Alfons.lua",
  "alfons.lua",
  "Alfons-moon",
  "alfons-moon",
  "Alfons-lua",
  "alfons-lua"
}
local load_alfons
load_alfons = function(f)
  local lf
  if f:match("lua") then
    lf = loadfile
  end
  if (f:match("moon")) and ms then
    lf = ms.loadfile
  else
    local fh = io.open(f, "r")
    local dump = fh:read("*all")
    fh:close()
    local lang = dump:match("%-%- alfons: ([a-z]+)")
    local _exp_0 = lang
    if "lua" == _exp_0 then
      lf = loadfile
    elseif "moon" == _exp_0 or "moonscript" == _exp_0 then
      if ms then
        lf = ms.loadfile
      end
    end
  end
  local env = gen_env()
  local fn, err = lf(f, "t", env, { })
  if err then
    error("Could not load file " .. tostring(f) .. ", " .. tostring(err))
  end
  fn()
  return env
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
if not arg then
  error("Must be called from command line!")
end
print(ltext.arrow("Reading tasks..."))
for i = 1, #arg do
  print(ltext.bullet(arg[i], false))
  if alfons[arg[i]] then
    alfons[arg[i]](arg[i])
  end
end
