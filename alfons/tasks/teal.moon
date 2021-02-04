tasks:
  -- always
  always: =>
    load "fetch"
    unless store.install == false
      tasks.install!
      tasks.typings modules: store.typings
  -- install dependencies
  install: =>
    -- pre-install hook
    if exists "teal_preinstall"
      prints "%{cyan}Teal:%{white} Running pre-install hook."
      tasks.teal_preinstall!
    -- install
    prints "%{cyan}Teal:%{white} Installing dependencies."
    for dep in *store.dependencies
      prints "%{green}+ #{dep}"
      sh "luarocks install #{dep}"
    -- post-install hook
    if exists "teal_postinstall"
      prints "%{cyan}Teal:%{white} Running post-install hook."
      tasks.teal_postinstall!
  -- build teal
  build: =>
    -- pre-install hook
    if exists "teal_prebuild"
      prints "%{cyan}Teal:%{white} Running pre-build hook."
      tasks.teal_prebuild!
    -- install
    prints "%{cyan}Teal:%{white} Building project."
    sh "tl build"
    -- post-install hook
    if exists "teal_postbuild"
      prints "%{cyan}Teal:%{white} Running post-build hook."
      tasks.teal_postbuild!
  -- download typings
  typings: =>
    -- import
    json = require "dkjson" -- uses dkjson
    -- define helper
    fetchdefs = (mod) ->
      prints "%{cyan}Teal:%{white} Fetching type definitions for #{mod}."
      unjson = tasks.fetch url: "https://api.github.com/repos/teal-language/teal-types/contents/types/#{mod}"
      files  = json.decode unjson
      for file in *files
        continue unless file.type == "file"
        name = file.name
        def  = tasks.fetch url: "https://raw.githubusercontent.com/teal-language/teal-types/master/types/#{mod}/#{name}"
        writefile name, def
    -- get arguments
    mod  = @m or @module
    mods = @modules
    if mod -- individual
      fetchdefs mod
    elseif mods -- multiple
      fetchdefs md for md in *mods