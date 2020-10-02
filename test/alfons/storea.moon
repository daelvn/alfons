tasks:
  always: =>
    store.test = "Hello World!"
    load "storeb"