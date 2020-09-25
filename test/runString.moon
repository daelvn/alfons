import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect" 

alfons     = runString readMoon "Alfons.moon"
tasks, env = alfons!

print inspect {:tasks,:env}
tasks.shello!