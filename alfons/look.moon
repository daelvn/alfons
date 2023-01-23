-- alfons.look
-- Gets the path for a module, specifically tailored for Alfons
import readMoon, readLua from require "alfons.file"
path                        = require "path"

sanitize = (pattern="") -> pattern\gsub "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0"

dirsep, pathsep, wildcard = package.config\match "^(.)\n(.)\n(.)"
modsep                    = "%."
swildcard                 = sanitize wildcard

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
      file = pt if path.exists pt
    for path in *moonpaths
      pt   = path\gsub swildcard, mod
      file = pt if path.exists pt
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

{ :makeLook, look: makeLook! }