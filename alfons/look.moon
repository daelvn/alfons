---# alfons.look #--
-- Gets the path for a module, specifically tailored for Alfons
import readMoon, readLua from require "alfons.file"
Path                        = require "path"

sanitize = (pattern="") -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0"

dirsep, pathsep, wildcard = package.config\match "^(.)\n(.)\n(.)"
modsep                    = "%."
swildcard                 = sanitize wildcard

--# API #--

--///--
-- FIXME: why is it generating double lines
--///--
--- @function makeLook :: gpath:string -> module:string -> content:string|nil, err:string|nil
--- Generate a function that looks for a module in a package path
makeLook = (gpath=package.path) ->
  -- generate lists of paths
  paths     = [path                        for path in gpath\gmatch "[^#{pathsep}]+"]
  moonpaths = [path\gsub "%.lua$", ".moon" for path in gpath\gmatch "[^#{pathsep}]+"]
  -- return
  (name) ->
    mod  = name\gsub modsep, dirsep
    file = false
    for path in *paths
      pt   = path\gsub swildcard, mod
      file = pt if Path.exists pt
    for path in *moonpaths
      pt   = path\gsub swildcard, mod
      file = pt if Path.exists pt
    --
    if file
      read                = (file\match "%.lua$") and readLua or readMoon
      content, contentErr = read file
      if content
        return content
      else
        return nil, contentErr
    else
      return nil, "#{name} not found."

--- @function look :: module:string -> content:string|nil, err:string|nil
--- @@@makeLook@@@ with `package.path` applied by default.
{ :makeLook, look: makeLook! }
