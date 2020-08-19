return {
  tasks = {
    fetch = function(self)
      local http = require("http.request")
      local headers, stream = assert((http.new_from_uri(self.url)):go())
      local body = assert(stream:get_body_as_string())
      if "200" ~= headers:get(":status") then
        return error(body)
      else
        return body
      end
    end
  }
}
