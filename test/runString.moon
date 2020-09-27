import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect" 

-- testing depths
print "== TESTING DEPTHS =="
alfons, err = runString readMoon "test/alfons/main.moon"
error err if err
env = alfons!

-- Always is nowalready run
--env.tasks.always!

-- normal task in main
env.tasks.hello!
print "---"
-- call task once-below main from task in main
env.tasks.execute!
print "---"
-- call task once-below main directly
env.tasks.subdirect!
print "---"
-- call task once-below main directly which calls a task once-above it (in main)
env.tasks.subcallup!
print "---"
-- loads a taskfile (twice-below main) from a taskfile once-below main
env.tasks.subdual!
print "---"
-- calls a task twice-below main
env.tasks.dusubloaded!
print "---"
-- calls a task twice-below main which calls a task once-below main
env.tasks.dusubcallup!
print "---"
-- calls a task twice-below main which calls a task once-below main, which
-- calls a task in main
env.tasks.dusubcalltop!
print "---"

-- testing load
print "== TESTING LOAD =="
alfons, err = runString readMoon "test/alfons/sidea.moon"
error err if err
env = alfons!

env.tasks.helloa!
env.tasks.hellob!