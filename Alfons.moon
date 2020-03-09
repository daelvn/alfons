-- tasks:
--   always:   => sh [[echo "hello from shell"]]
--   other:    => print "hello"
--   teardown: => print "teardown"
--   default:  => print "default"
--   inspect:  (...) =>
--     i = require "inspect"
--     print i @
--     print i {...}

export always   ==> sh [[echo "hello from shell"]]
export other    ==> print "hello"
export teardown ==> print "teardown"
export default  ==> print "default"
export inspect  = (...) =>
  i = require "inspect"
  print i @
  print i {...}