(url) =>
  -- TODO an async version of fetchs would be cool
  if http and http.get
    -- on ComputerCraft
    urlh    = http.get url
    content = urlh.readAll!
    urlh.close!
    return content
  elseif pcall -> require "http.request"
    -- on lua-http
    http            = require "http.request"
    headers, stream = (http.new_from_uri url)\go!
    body            = stream\get_body_as_string!
    return body, headers
  else
    error "No HTTP provider found. Please enable the HTTP API or download lua-http (rock: http)."