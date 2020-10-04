function always()
  print "Hello from Lua!"
  load "subalf"
end

function runTask()
  print "Running from Lua!"
end

function fromMoon()
  tasks.subloaded()
end