tasks:
  subloaded: => print @name
  subdirect: => print @name
  subbelow:  => print @name
  subcallup: =>
    print @name
    tasks.hello!
  subdual: =>
    print @name
    load "dusubalf"