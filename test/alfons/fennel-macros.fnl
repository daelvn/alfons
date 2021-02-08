(deftasks
  (task :always []
    (print "Hello from Fennel!")
    (load "subalf"))
  (task :runTask []
    (print "Running from Fennel!"))
  (task :fromMoon []
    (tasks.subloaded)))