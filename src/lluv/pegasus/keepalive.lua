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

local KeepAlive = require "pegasus.keepalive"

local LluvKeepAlive = setmetatable({}, KeepAlive) do
LluvKeepAlive.__index = LluvKeepAlive

local function is_socket_alive(s)
  return s and s._sock ~= nil
end

local function socket_interrupt(s)
  return s:interrupt()
end

local function clone(t)
  local o = {}
  for k,v in pairs(t) do
    t[k] = v
  end
  return o
end

function LluvKeepAlive:new(opt)
  opt = opt and clone(opt) or {}
  opt.socket_test = is_socket_alive
  opt.socket_close = socket_interrupt

  return KeepAlive.new(self, opt)
end

end

return LluvKeepAlive