return function(self, url)
  if http and http.get then
    local urlh = http.get(url)
    local content = urlh.readAll()
    urlh.close()
    return content
  elseif pcall(function()
    return require("socket")
  end) then
    local http = require("socket.http")
    local content, code, headers = http.request(url)
    return content
  else
    return error("No HTTP provider found. Please enable the HTTP API or download LuaSocket.")
  end
end
