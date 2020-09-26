import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect" 

alfons, err = runString readMoon "test/alfons/main.moon"
error err if err
env = alfons!

env.tasks.always!
env.tasks.execute!