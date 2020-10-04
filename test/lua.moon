import runString from require "alfons"
import readLua   from require "alfons.file"
inspect             = require "inspect"

-- testing lua taskfiles
alfons, err = runString readLua "test/alfons/lua.lua"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!