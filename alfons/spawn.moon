-- alfons.spawn
-- Spawns a task as an independent process

getOS = ->
  switch package.cpath\match "%p[#{package.config:sub(1,1)}]?%p(%a+)"
    when "dll" then return "Windows"
    when "so" then return "Linux"
    when "dylib" then return "MacOS"
    else return "Unknown"


