-- alfons.file
-- Gets the contents of a taskfile
fs = require "filekit"

readMoon = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      error "loadMoon :: Could not open #{file}: #{.error}"
      os.exit 1
    -- read and compile
    import to_lua from require "moonscript.base"
    content, err = to_lua \read "*a"
    -- check that we could compile correctly
    unless content
      error "loadMoon :: Could not read or parse #{file}: #{err}"
      os.exit 1
    \close!
  -- return
  return content

readLua = (file) ->
  local content
  with fs.safeOpen file, "r"
    -- check that we could open correctly
    if .error
      error "readLua :: Could not open #{file}: #{.error}"
      os.exit 1
    -- read and compile
    content = \read "*a"
    -- check that we could compile correctly
    unless content
      error "readLua :: Could not read #{file}: #{content}"
      os.exit 1
    \close!
  -- return
  return content

{ :readMoon, :readLua }