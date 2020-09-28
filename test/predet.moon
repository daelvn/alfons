import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect"

-- testing default and finalize tasks
alfons, err = runString readMoon "test/alfons/predet.moon"
error err if err
env = alfons!

-- check count
print env.__ran -- 0
env.tasks.first!
print env.__ran -- 1
-- reset
alfons, err = runString readMoon "test/alfons/predet.moon"
env         = alfons!
print "---"

-- finalize (2 defaults and 2 finalizes)
env.finalize!
-- reset
alfons, err = runString readMoon "test/alfons/predet.moon"
env         = alfons!
print "---"

-- finalize, one default
env.tasks.first!
env.finalize!
-- reset
alfons, err = runString readMoon "test/alfons/predet.moon"
env         = alfons!
print "---"

-- finalize, another default
env.tasks.second!
env.finalize!
-- reset
alfons, err = runString readMoon "test/alfons/predet.moon"
env         = alfons!
print "---"