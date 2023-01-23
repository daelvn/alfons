-- alfons.wildcard
-- Reimplements the old filekit wildcard behavior
Path = require "path"
fs   = require "path.fs"

-- listAll (dir:string) -> [string]
-- Filekit's listAll
listAll = (dir) -> [node for node in fs.scandir dir]

-- Turns a glob into a Lua pattern
-- @tparam string glob Path with globs
-- @treturn string Lua pattern
fromGlob = (glob) ->
  sanitize = (pattern) -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0" if pattern
  saglob   = sanitize glob
  with saglob
    mid = \gsub "%%%*%%%*",    ".*"
    mid = mid\gsub "%%%*",     "[^/]*"
    mid = mid\gsub "%%%?",     "." -- TODO this should be [^/]
    print "==> #{mid}"
    return "#{mid}$"

-- TODO alias this to testGlob
-- TODO compile the glob here, dont make the user do it
--- Matches a compiled glob with a string
-- @tparam string glob Compiled glob
-- @tparam string path Path to compare to
-- @treturn boolean Whether it matches or not
matchGlob = (glob, path) -> nil != path\match glob

--- Returns a list of paths matched by the globs
-- @tparam string path Path with globs
-- @treturn table Table of globbed files
glob = (path, all={}) ->
  -- Return if there is nothing to glob
  return path unless path\match "%*"
  -- Get full paths
  --currentpath = Path.cwd!
  --fullpath    = Path currentpath, path
  currentpath = "."
  fullpath    = path
  -- Create a correct listing
  correctpath = ""
  for i=1, #fullpath
    if (fullpath\sub i, i) == (currentpath\sub i, i)
      correctpath ..= currentpath\sub i, i
  -- Create glob
  toglob      = fromGlob fullpath
  -- Iterate files
  for node in *listAll correctpath
    --print node, toglob
    table.insert all, node if node\match toglob
  -- Return
  return all

--- Glob as an iterator
-- @tparam string path Path with globs
-- @treturn function Iterator
iglob = (path) ->
  globbed = glob path
  i       = 0
  n       = #globbed
  return ->
    i += 1
    if i <= n then return globbed[i]

{
  :listAll
  :fromGlob, :matchGlob, :glob, :iglob
}