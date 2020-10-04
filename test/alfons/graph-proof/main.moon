tasks:
  always: =>
    load "a"
    load "b"
    load "c"
  main: => print @name