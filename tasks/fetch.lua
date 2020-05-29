return function(self, url)
  print(style("%{red}fetch is deprecated and will be removed in a future update."))
  print(style("%{red}Consider using fetchs (task) instead."))
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
    return content, code, headers
  else
    return error("No HTTP provider found. Please enable the HTTP API or download LuaSocket.")
  end
end
