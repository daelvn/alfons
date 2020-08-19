tasks:
  fetch: =>
    http            = require "http.request"
    headers, stream = assert (http.new_from_uri "https://example.com")\go!
    body            = assert stream\get_body_as_string!
    if "200" != headers\get ":status"
      error body
    else
      return body