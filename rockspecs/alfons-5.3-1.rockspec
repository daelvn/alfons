build = {
  install = {
    bin = {
      alfons = "alfons.lua"
    }
  },
  modules = {
    ["alfons.tasks.fetch"] = "alfons/tasks/fetch.lua"
  },
  type = "builtin"
}
dependencies = {
  "lpath",
  "ansikit",
  "lua >= 5.1"
}
description = {
  detailed = "alfons is a small script utility that lets you run tasks from a file (Lua or MoonScript), to better manage your project with tasks such as clean, compile, etc. To run tasks from a MoonScript file, you will need the moonscript rock.\n",
  homepage = "https://github.com/daelvn/alfons",
  summary = "Small program to run tasks for your project"
}
package = "alfons"
rockspec_format = "3.0"
source = {
  tag = "v5.3",
  url = "git://github.com/daelvn/alfons"
}
version = "5.3-1"
