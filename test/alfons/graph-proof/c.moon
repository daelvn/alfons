tasks:
  always: => load "f"
  c: => print @name
  doc: =>
    tasks.a!
    tasks.b!
    tasks.c!
    tasks.d!
    tasks.e!
    tasks.f!