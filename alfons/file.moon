-- alfons.file
-- Gets the contents of a taskfile
safeOpen = (path, mode) ->
  a, b = io.open path, mode
  return a and a or {error: b}

readMoon = (file) ->
  local content
  with safeOpen file, "r"
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

readFile = (file) ->
  local content
  with safeOpen file, "r"
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

readLua = readFile

-- REQUIRES "tl" MODULE
readTeal = (file) ->
  local content
  with safeOpen file, "r"
    -- check that we could open correctly
    if .error
      return nil, "Could not open #{file}: #{.error}"
    -- read and compile
    import init_env, gen from require "tl"
    gwe     = init_env true, false -- lax:true, compat:false
    content = gen (\read "*a"), gwe
    -- check that we could compile correctly
    unless content
      return nil, "Could not read #{file}: #{content}"
    \close!
  -- return
  return content

{ :readMoon, :readLua, :readTeal, :readFile }
