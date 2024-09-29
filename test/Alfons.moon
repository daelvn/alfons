tasks:
  -- dummy tasks
  hello:  => print "hello!"
  shello: => sh "echo 'hello!'"
  args:   =>
    inspect = require "inspect"
    print inspect args
    print inspect @
    print inspect store
    print inspect calls!
  reargs: => tasks.args!
  wild: =>
    for file in wildcard "./**.moon"
      print file
  where: =>
    inspect = require 'inspect'
    print inspect debug.getinfo 1
  cmdread: =>
    show cmdread "echo 'hi'"
  reduce: =>
    t = {1, 2, 3}
    reduced = reduce t, ((acc, e) ->
      print 'accv', acc.v
      print 'e', e
      return {v: acc.v + e}
    ), { v: 0 }
    show reduced.v
