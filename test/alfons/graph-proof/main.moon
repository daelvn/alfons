tasks:
  always: =>
    load "graph-proof.a"
    load "graph-proof.b"
    load "graph-proof.c"
  main: => print @name