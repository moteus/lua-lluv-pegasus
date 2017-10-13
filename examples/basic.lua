local uv      = require "lluv"
local Pegasus = require "lluv.pegasus"

local server = Pegasus.new{host = '127.0.0.1', port = 9090}

server:startAsync(function(request, response)
  response:statusCode(200)
  response:addHeader('Content-Type', 'text/plain')
  response:write('Hello from Pegasus')
end)

uv.run()