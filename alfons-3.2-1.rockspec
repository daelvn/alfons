package = "alfons"
version = '3.2-1'
source = {
  url = "git://github.com/daelvn/alfons",
  tag = 'v3.2'
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
  "filekit >= 1.3",
  "ansikit",
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["alfons.tasks.publish-rockspec"] = "tasks/publish-rockspec.lua",
    ["alfons.tasks.ms-compile"] = "tasks/ms-compile.lua",
  },
  install = {
    bin = {
      alfons = "alfons.lua"
    }
  }
}
