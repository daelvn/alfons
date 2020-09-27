tasks:
  always:  => load "subalf"
  hello:   => print @name
  shello:  => sh "echo 'Hello from sh!'"
  execute: =>
    print @name
    tasks.subloaded!