tasks:
  always: =>
    load "d"
    load "e"
  a: => print @name
  doa: =>
    tasks.a!
    tasks.b!
    tasks.c!
    tasks.d!
    tasks.e!
    tasks.f!