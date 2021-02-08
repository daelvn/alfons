(global always (fn []
                 (print "Hello from Fennel!")
                 (load "subalf")))

(global runTask (fn []
                  (print "Running from Fennel!")))

(global fromMoon (fn []
                   (tasks.subloaded)))