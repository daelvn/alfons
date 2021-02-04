import runString from require "alfons"
import readTeal  from require "alfons.file"

-- testing teal taskfiles
print "teal (globals)"
alfons, err = runString readTeal "test/alfons/teal.tl"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!

--
print "teal (table)"
alfons, err = runString readTeal "test/alfons/teal-table.tl"
error err if err
env = alfons!

env.tasks.runTask!
env.tasks.fromMoon!