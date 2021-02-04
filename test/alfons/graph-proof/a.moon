tasks:
  always: =>
    load "graph-proof.d"
    load "graph-proof.e"
  a: => print @name
  doa: =>
    tasks.a!
    tasks.b!
    tasks.c!
    tasks.d!
    tasks.e!
    tasks.f!