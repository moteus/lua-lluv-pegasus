local uv       = require "lluv"
local Pegasus  = require 'lluv.pegasus'
local Compress = require 'pegasus.compress'

local server = Pegasus:new({
  port='9090',
  location='./examples/root',
  -- plugins = { Compress:new() }
})

server:start(function(req, rep)
end)

uv.run()