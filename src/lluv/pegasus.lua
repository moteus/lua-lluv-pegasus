------------------------------------------------------------------
--
--  Author: Alexey Melnichuk <alexeymelnichuck@gmail.com>
--
--  Copyright (C) 2017 Alexey Melnichuk <alexeymelnichuck@gmail.com>
--
--  Licensed according to the included 'LICENCE' document
--
--  This file is part of lluv-pegasus library.
--
------------------------------------------------------------------

local uv        = require 'lluv'
local ut        = require 'lluv.utils'
local socket    = require 'lluv.luasocket'
local File      = require 'lluv.pegasus.file'
local Handler   = require 'pegasus.handler'
local Request   = require 'pegasus.request'
local Response  = require 'pegasus.response'
local mimetypes = require 'mimetypes'

local _M = {
  _NAME      = 'lluv-pegasus';
  _VERSION   = '0.1.0-dev';
  _COPYRIGHT = 'Copyright (C) 2017 Alexey Melnichuk';
  _LICENSE   = "MIT";
}

-- Hack to add `getpeername` to lluv.luasocket.
local TcpSocket = assert(socket._TcpSocket)
if not TcpSocket.getpeername then

function TcpSocket:getpeername()
  if not self._sock then return nil, self._err end

  return self._sock:getpeername()
end

end

-- Overwrite Handler class to use my `cofs` module
local CoHandler = setmetatable({}, {__index = Handler}) do

function CoHandler:processRequest(port, client)
  local request    = Request:new(port, client)
  local response   = Response:new(client, self)
  response.request = request

  local stop = self:pluginsNewRequestResponse(request, response)
  if stop then return end

  local path = request:path()

  if path and #self.location > 0 then
    local filename
    if path == '/' or #path == 0 then
      filename = File:getIndex(self.location)
    else
      filename = File:pathJoin(self.location, request:path())
    end

    if not (filename and File:exists(filename)) then
      response:statusCode(404)
    else
      stop = self:pluginsProcessFile(request, response, filename)

      if stop then return end

      local file = File:open(filename)

      if file then
        response:writeFile(file, mimetypes.guess(filename or '') or 'text/html')
        file:close() -- pegasus 0.9.3 does not close file
      else
        response:statusCode(404)
      end
    end
  end

  if self.callback then
    -- response:statusCode(200)
    -- response.headers = {}
    -- response:addHeader('Content-Type', 'text/html')
    self.callback(request, response)
  end

  if response.status == 404 then
    response:writeDefaultErrorMessage(404)
  end
end

end

local Pegasus = ut.class() do

function Pegasus:__init(params)
  self._port     = params and params.port or 9090
  self._host     = params and params.host or '*'
  self._location = params and params.location or ''
  self._plugins  = params and params.plugins or {}
  self._callback = params and params.callback

  if #self._location > 0 then
    self._location = File:fullPath(self._location) or ''
  end

  return self
end

-- run from new thread
local function on_accept(self, client)
  local handler = CoHandler:new(self._callback, self._location, self._plugins)
  handler:processRequest(PORT, client:attach())
end

function Pegasus:startSync(callback)
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

  print(string.format("%s (%s) is up on %s:%s", 
    _M._NAME, _M._VERSION, tostring(ip), tostring(port)
  ))

  while true do
    ok, err = srv:accept()

    if not ok then break end

    ut.corun(on_accept, self, ok)
  end

  if not ok then return nil, err end

  return true
end

function Pegasus:start(...)
  return ut.corun(self.startSync, self, ...)
end

end

function _M.new(t, ...)
  if t == _M then
    return Pegasus.new(...)
  end
  return Pegasus.new(t, ...)
end

return _M