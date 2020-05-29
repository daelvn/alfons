return function(self, url)
  if http and http.get then
    local urlh = http.get(url)
    local content = urlh.readAll()
    urlh.close()
    return content
  elseif pcall(function()
    return require("http.request")
  end) then
    local http = require("http.request")
    local headers, stream = (http.new_from_uri(url)):go()
    local body = stream:get_body_as_string()
    return body, headers
  else
    return error("No HTTP provider found. Please enable the HTTP API or download lua-http (rock: http).")
  end
end
