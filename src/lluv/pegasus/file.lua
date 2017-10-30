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

-- luacheck: ignore self

local uv   = require 'lluv'
local cofs = require 'lluv.cofs'
local path = require 'path'

local File = {}

function File:isDir(p)
  p = path.normalize(p)

  local stat = uv.fs_stat(p)
  return stat and stat.is_directory
end

function File:exists(p)
  p = path.normalize(p)
  return not not uv.fs_access(p)
end

function File:size(p)
  p = path.normalize(p)

  local stat = uv.fs_stat(p)
  return stat and stat.size
end

function File:pathJoin(p, ...)
  return path.join(p, ...)
end

function File:fullPath(p)
  return path.isfullpath(p) or
    path.join(uv.cwd(), p)
end

function File:getIndex(p)
  local filename = path.normalize(self:pathJoin(p, 'index.html'))

  if self:exists(filename) then return filename end

  filename = path.normalize(self:pathJoin(p, 'index.htm'))

  if self:exists(filename) then return filename end

  return nil
end

function File:open(p)
  local filename = p

  if self:isDir(p) then
    filename = self:getIndex(p)
    if not filename then return nil end
  end

  local file, err = cofs.open(filename, 'rb')

  if not file then return nil, err end

  return file, filename
end

return File
