import runString from require "alfons"
import readFennel   from require "alfons.file"
inspect                = require "inspect"

-- testing fennel taskfiles
print "fennel (globals)"
alfons, err = runString readFennel "test/alfons/fennel-globals.fnl"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!

--
print "fennel (table)"
alfons, err = runString readFennel "test/alfons/fennel-table.fnl"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!

--
print "fennel (macros)"
alfons, err = runString readFennel "test/alfons/fennel-macros.fnl"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!