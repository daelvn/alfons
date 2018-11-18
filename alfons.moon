-- alfons | 14.11.2018
-- By daelvn
-- Project management helper
ltext = require "ltext"
file  = require "file"
local ms
if not pcall ->
    ms = require "moonscript.base"
  ms = false

print ltext.title "alfons 14.11.2018"

gen_env = -> {
  -- Provided libraries
  :ltext
  :file
  -- Provided standard modules
  :coroutine
  :table
  :io
  :os
  :string
  :math
  -- Provided functions
  :assert
  :error
  :pcall

  :dofile
  :load
  :loadfile
  :require

  :next
  :ipairs
  :pairs
  :ipairs
  :select

  :tonumber
  :tostring
  :type

  :print
}

files = {
  "Alfons"
  "alfons"
  "Alfons.moon"
  --"alfons.moon"
  "Alfons.lua"
  "alfons.lua"
  "Alfons-moon"
  "alfons-moon"
  "Alfons-lua"
  "alfons-lua"
}

load_alfons = (f) ->
  local lf
  if f\match "lua"           then lf = loadfile
  if (f\match "moon") and ms then lf = ms.loadfile
  else
    fh   = io.open f, "r"
    dump = fh\read "*all"
    fh\close!
    lang = dump\match "%-%- alfons: ([a-z]+)"
    switch lang
      when "lua"               then lf = loadfile
      when "moon","moonscript" then lf = ms.loadfile if ms
  env     = gen_env!
  fn, err = lf f, "t", env, {}
  error "Could not load file #{f}, #{err}" if err
  fn!
  return env

load_alfons_51 = (f) ->
  local lf
  if f\match "lua"           then lf = loadfile
  if (f\match "moon") and ms then lf = ms.loadfile
  else
    fh   = io.open f, "r"
    dump = fh\read "*all"
    fh\close1
    land = dump\match "%-%- alfons: ([a-z]+)"
    switch lang
      when "lua"               then lf = loadfile
      when "moon","moonscript" then lf = ms.loadfile if ms
  env     = gen_env!
  fn, err = lf f
  error "Could not load file #{f}, #{err}" if err
  setfenv fn, env
  fn!
  return env

print ltext.arrow "Finding files..."
local alfons
for f in *files
  print ltext.dart "Trying with #{f}"
  if file.exists f
    print ltext.bullet "Found!"
    switch tonumber _VERSION\match "Lua 5.(%d)"
      when 3 then alfons = load_alfons f
      when 1 then alfons = load_alfons_51 f
      else alfons = load_alfons f
    break

error "Must be called from command line!" if not arg
print ltext.arrow "Reading tasks..."
for i=1,#arg
  print ltext.bullet arg[i], false
  if alfons[arg[i]] then alfons[arg[i]] arg[i]
