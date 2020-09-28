tasks:
  always:   => load "predet2"
  first:    => print @name
  default:  => print @name
  finalize: => print @name