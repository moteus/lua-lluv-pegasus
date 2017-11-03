local uv        = require "lluv"
local Pegasus   = require "lluv.pegasus"
local KeepAlive = require 'lluv.pegasus.keepalive'

local server = Pegasus.new{
  host = '127.0.0.1', port = 9090;
  plugins = {KeepAlive:new{
    wait_timeout    = 60;
    request_timeout = 5;
    requests        = 10;
    connections     = 10;
  }}
}

server:start(function(request, response)
  print(request, ' - precess')
  request:headers()

  response:statusCode(200)
  response:addHeader('Content-Type', 'text/plain')
  response:write('Hello from Pegasus')
end)

uv.run()
