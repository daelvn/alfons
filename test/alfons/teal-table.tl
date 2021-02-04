return { tasks = {
  always = function()
    print "Hello from Teal!"
    load "subalf"
  end,
  runTask = function()
    print "Running from Teal!"
  end,
  fromMoon = function()
    tasks.subloaded()
  end
}}