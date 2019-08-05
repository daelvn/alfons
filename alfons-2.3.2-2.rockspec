package = "alfons"
version = '2.3.2-2'
source = {
  url = "git://github.com/daelvn/alfons",
  tag = 'v2.3.2-2'
}
description = {
  summary = "Small program to run tasks for your project",
  detailed = [[
    alfons is a small script utility that lets you run tasks
    from a file (Lua or MoonScript), to better manage your
    project with tasks such as clean, compile, etc. To run
    tasks from a MoonScript file, you will need the
    moonscript rock.]],
  homepage = "https://github.com/daelvn/alfons",
}
dependencies = {
  "ltext",
  "lua >= 5.0"
}
build = {
  type = "builtin",
  modules = {
    file = "file.lua"
  },
  install = {
    bin = {
      alfons = "alfons.lua"
    }
  }
}
