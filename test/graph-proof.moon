import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect"

-- testing the graph in docs/loading.md
alfons, err = runString readMoon "test/alfons/graph-proof/main.moon"
error err if err
env = alfons!

print "-> (main)"
env.tasks.a!
env.tasks.b!
env.tasks.c!
env.tasks.d!
env.tasks.e!
env.tasks.f!
print "-> a"
env.tasks.doa!
print "-> b"
env.tasks.dob!
print "-> c"
env.tasks.doc!
print "-> d"
env.tasks.dod!
print "-> e"
env.tasks.doe!
print "-> f"
env.tasks.dof!