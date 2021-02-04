global function always()
  print "Hello from Teal!"
  load "subalf"
end

global function runTask()
  print "Running from Teal!"
end

global function fromMoon()
  tasks.subloaded()
end