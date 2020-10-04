-- alfons.env
-- Loading and custom environment
import style   from require "ansikit.style"
setfenv         or= require "alfons.setfenv"
fs                = require "filekit"
unpack          or= table.unpack

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

-- load in environment
-- loadEnv content:string, env:table -> fn:function | nil, err:string
loadEnv = (content, env) ->
  local fn
  switch _VERSION
    -- use loadstring on 5.1
    when "Lua 5.1"
      fn, err = loadstring content
      unless fn
        return nil, "Could not load Alfonsfile content (5.1): #{err}"
      setfenv fn, env
    -- use load otherwise
    when "Lua 5.2", "Lua 5.3", "Lua 5.4"
      fn, err = load content, "Alfons", "t", env
      unless fn
        return nil, "Could not load Alfonsfile content (5.2+): #{err}"
  -- return
  return fn

{
  :ENVIRONMENT
  :loadEnv
}