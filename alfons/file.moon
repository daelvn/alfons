-- alfons.file
-- Gets the contents of a taskfile
import printError from require "alfons.provide"
fs                   = require "filekit"

readMoon = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      printError "loadMoon :: Could not open #{file}: #{.error}"
      os.exit 1
    -- read and compile
    import to_lua from require "moonscript.base"
    content, err = to_lua \read "*a"
    -- check that we could compile correctly
    unless content
      printError "loadMoon :: Could not read or parse #{file}: #{err}"
      os.exit 1
    \close!
  -- return
  return content

readLua = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      printError "readLua :: Could not open #{file}: #{.error}"
      os.exit 1
    -- read and compile
    content = \read "*a"
    -- check that we could compile correctly
    unless content
      printError "readLua :: Could not read #{file}: #{content}"
      os.exit 1
    \close!
  -- return
  return content

{ :readMoon, :readLua }