build = {
  install = {
    bin = {
      alfons = "bin/alfons.lua"
    }
  },
  modules = {
    ["alfons.env"] = "alfons/env.lua",
    ["alfons.file"] = "alfons/file.lua",
    ["alfons.getopt"] = "alfons/getopt.lua",
    ["alfons.init"] = "alfons/init.lua",
    ["alfons.look"] = "alfons/look.lua",
    ["alfons.provide"] = "alfons/provide.lua",
    ["alfons.setfenv"] = "alfons/setfenv.lua",
    ["alfons.tasks.fetch"] = "alfons/tasks/fetch.lua",
    ["alfons.tasks.teal"] = "alfons/tasks/teal.lua",
    ["alfons.version"] = "alfons/version.lua",
    ["alfons.wildcard"] = "alfons/wildcard.lua"
  },
  type = "builtin"
}
dependencies = {
  "lpath",
  "ansikit",
  "lua >= 5.1",
  "inotify",
  "http"
}
description = {
  detailed = "The normal 'alfons' package is bundled, making all modules unavailable. 'alfons-dev' installs them without bundling.\n",
  homepage = "https://github.com/daelvn/alfons",
  summary = "Unpacked Alfons modules for development"
}
package = "alfons-dev"
rockspec_format = "3.0"
source = {
  tag = "v5.0.2",
  url = "git://github.com/daelvn/alfons"
}
version = "5.0.2-1"
