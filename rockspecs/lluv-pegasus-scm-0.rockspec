package = "lluv-pegasus"
version = "scm-0"

source = {
  url = "https://github.com/moteus/lua-lluv-pegasus/archive/master.zip",
  dir = "lua-lluv-pegasus-master",
}

description = {
  summary    = "Simple server based on pegasus.lua",
  homepage   = "https://github.com/moteus/lua-lluv-pegasus",
  license    = "MIT/X11",
  maintainer = "Alexey Melnichuk",
  detailed   = [[
  ]],
}

dependencies = {
  "lua >= 5.1, < 5.4",
  "pegasus > 0.9.2",
  "lluv",
  "lua-path",
}

build = {
  copy_directories = {'examples'},

  type = "builtin",

  modules = {
    [ "lluv.pegasus"      ] = "src/lluv/pegasus.lua",
    [ "lluv.pegasus.file" ] = "src/lluv/pegasus/file.lua",
  }
}
