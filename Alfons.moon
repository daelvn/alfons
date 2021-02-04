tasks:
  make:    => sh "rockbuild -m --delete #{@v}" if @v
  release: => sh "rockbuild -m -t #{@v} u"     if @v
  -- compile everything
  compile: =>
    sh "moonc #{file}" for file in wildcard "alfons/**.moon"
    sh "moonc bin/alfons.moon"
  -- clean everything
  clean: =>
    show "Cleaning files"
    for file in wildcard "**.lua"
      continue if (file\match "alfons.lua") and not (file\match "bin")
      continue if (file\match "tasks")
      fs.delete file
  -- use amalg to pack Alfons
  pack: =>
    show "Packing using amalg.lua"
    @o    or= @output or "alfons.lua"
    @s    or= @entry or "bin/alfons.lua"
    modules = for file in wildcard "alfons/*.moon" do "alfons.#{filename file}"
    tasks   = for file in wildcard "alfons/tasks/*.moon" do "alfons.tasks.#{filename file}"
    sh "amalg.lua -o #{@o} -s #{@s} #{table.concat modules, ' '} #{table.concat tasks, ' '}"
  -- generate only alfons.lua
  produce: =>
    tasks.compile!
    tasks.pack!
    tasks.clean!
  -- run tests
  test: => sh "moon test/#{@n or ''}.moon"
  -- dummy tasks
  hello:  => print "hello!"
  shello: => sh "echo 'hello!'"
  args:   =>
    inspect = require "inspect"
    print inspect args
    print inspect @
    print inspect store
    print inspect calls!
  reargs: => tasks.args!
  -- teal
  always: =>
    store.install = false
    load "teal"