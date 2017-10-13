local uv      = require "lluv"
local ut      = require "lluv.utils"
local socket  = require 'lluv.luasocket'
local Handler = require 'pegasus.handler'

-- Hack to add `getpeername` to lluv.luasocket.
local TcpSocket = assert(socket._TcpSocket)
if not TcpSocket.getpeername then

function TcpSocket:getpeername()
  if not self._sock then return nil, self._err end

  return self._sock:getpeername()
end

end

local Pegasus = ut.class() do

function Pegasus:__init(params)
  self._port     = params and params.port or 9090
  self._host     = params and params.host or '*'
  self._location = params and params.location or ''
  self._plugins  = params and params.plugins or {}
  self._callback = params and params.callback

  return self
end

-- run from new thread
local function on_accept(self, client)
  local handler = Handler:new(self._callback)
  handler:processRequest(PORT, client:attach())
end

function Pegasus:start(callback)
  self._callback = callback or self._callback

  local srv = socket.tcp()

  local ok, err = srv:bind(self._host, self._port)

  if not ok then
    srv:close()
    return nil, err
  end

  local ip, port = srv:getsockname()
  if not ip then
    srv:close()
    return nil, port
  end

  print('Pegasus is up on ' .. ip .. ":".. port)

  while true do
    ok, err = srv:accept()

    if not ok then break end

    ut.corun(on_accept, self, ok)
  end

  if not ok then return nil, err end

  return true
end

function Pegasus:startAsync(...)
  return ut.corun(self.start, self, ...)
end

end

return {
	new = Pegasus.new;
}
