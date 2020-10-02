import runString from require "alfons"
import readMoon  from require "alfons.file"
inspect             = require "inspect" 

-- testing store table
alfons, err = runString readMoon "test/alfons/storea.moon"
error err if err
env = alfons!

env.tasks.test!