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
  :ltext
  :file
  :print
  :io
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

print ltext.arrow "Finding files..."
local alfons
for f in *files
  print ltext.dart "Trying with #{f}"
  if file.exists f
    print ltext.bullet "Found!"
    alfons = load_alfons f
    break

error "Must be called from command line!" if not arg
print ltext.arrow "Reading tasks..."
for i=1,#arg
  print ltext.bullet arg[i], false
  if alfons[arg[i]] then alfons[arg[i]] arg[i]
