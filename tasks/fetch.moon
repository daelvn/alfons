(url) =>
  print style "%{red}fetch is deprecated and will be removed in a future update."
  print style "%{red}Consider using fetchs (task) instead."
  if http and http.get
    -- on ComputerCraft
    urlh    = http.get url
    content = urlh.readAll!
    urlh.close!
    return content
  elseif pcall -> require "socket"
    -- on luasocket
    http                   = require "socket.http"
    content, code, headers = http.request url
    return content, code, headers
  else
    error "No HTTP provider found. Please enable the HTTP API or download LuaSocket."