tasks:
  d: => print @name
  dod: =>
    tasks.a!
    tasks.b!
    tasks.c!
    tasks.d!
    tasks.e!
    tasks.f!