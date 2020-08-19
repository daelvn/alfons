-- alfons.env
-- Loading and custom environment
import setfenv from require "alfons.compat"
import style   from require "ansikit.style"
fs                = require "filekit"
provide           = require "alfons.provide"

-- forward-declare environment
local ENVIRONMENT

-- environment for alfons files
ENVIRONMENT = {
  :_VERSION
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
}

-- add our own
for k, v in pairs provide
  ENVIRONMENT[k] = v

-- generate keylist
KEYS = [k for k, v in pairs ENVIRONMENT]

-- load in environment
loadEnv = (content, env) ->
  local fn
  switch _VERSION
    -- use loadstring on 5.1
    when "Lua 5.1"
      fn, err = loadstring content
      unless fn
        printerr "loadEnv-5.1 :: Could not load Alfonsfile content: #{err}"
        os.exit 1
      setfenv fn, env
    -- use load otherwise
    when "Lua 5.2", "Lua 5.3", "Lua 5.4"
      fn, err = load content, "Alfons", "t", env
      unless fn
        printerr "loadEnv :: Could not load Alfonsfile content: #{err}"
        os.exit 1
  -- return
  return fn

{
  :ENVIRONMENT, :KEYS
  :loadEnv
}