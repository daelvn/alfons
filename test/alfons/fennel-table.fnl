{:tasks {:always (fn []
                   (print "Hello from Fennel!")
                   (load "subalf"))
         :runTask (fn []
                    (print "Running from Fennel!"))
         :fromMoon (fn []
                     (tasks.subloaded))}}