-- alfons.file
-- Gets the contents of a taskfile
fs = require "filekit"

readMoon = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      return nil, "Could not open #{file}: #{.error}"
    -- read and compile
    import to_lua from require "moonscript.base"
    content, err = to_lua \read "*a"
    -- check that we could compile correctly
    unless content
      return nil, "Could not read or parse #{file}: #{err}"
    \close!
  -- return
  return content

readLua = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      return nil, "Could not open #{file}: #{.error}"
    -- read and compile
    content = \read "*a"
    -- check that we could compile correctly
    unless content
      return nil, "Could not read #{file}: #{content}"
    \close!
  -- return
  return content

{ :readMoon, :readLua }