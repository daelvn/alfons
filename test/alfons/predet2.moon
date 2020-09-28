tasks:
  second:   => print @name
  default:  => print @name .. "2"
  finalize: => print @name .. "2"