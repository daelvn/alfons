tasks:
  --- @task make Install a local version of a version
  --- @option make [v] <version:string> Current version
  make:    => sh "rockbuild -m --delete #{@v}" if @v
  --- @task release Create and upload a release of Alfons using %{magenta}`rockbuild`%{reset}.
  --- @option release [v] <version:string> Current version
  release: => sh "rockbuild -m -t #{@v} u"     if @v
  --- @task compile Compile all MoonScript files
  compile: =>
    sh "moonc #{file}" for file in wildcard "alfons/**.moon"
    sh "moonc bin/alfons.moon"
  --- @task clean Clean all built files
  clean: =>
    show "Cleaning files"
    for file in wildcard "**.lua"
      continue if (file\match "alfons.lua") and not (file\match "bin")
      continue if (file\match "tasks")
      delete file
  --- @task pack Pack an Alfons build using amalg.lua
  --- @option pack [output o] <file> Output file (Default: %{green}"alfons.lua"%{reset})
  --- @option pack [entry s] <file> Entry file (Default: %{green}"bin/alfons.lua"%{reset})
  pack: =>
    show "Packing using amalg.lua"
    @o    or= @output or "alfons.lua"
    @s    or= @entry or "bin/alfons.lua"
    modules = for file in wildcard "./alfons/*.moon" do "alfons.#{filename file}"
    tasks   = for file in wildcard "./alfons/tasks/*.moon" do "alfons.tasks.#{filename file}"
    show "amalg.lua -o #{@o} -s #{@s} #{table.concat modules, ' '} #{table.concat tasks, ' '}"
    sh "amalg.lua -o #{@o} -s #{@s} #{table.concat modules, ' '} #{table.concat tasks, ' '}"
  --- @task produce Generate %{green}`alfons.lua`%{reset}
  produce: =>
    tasks.compile!
    tasks.pack!
    tasks.clean!
  --- @task test Run an Alfons test
  --- @option test [n] <name> Name of the test to run
  test: =>
    path = "test/#{@n or ''}"
    if fs.exists "#{path}.yue"
      sh "yue alfons"
      sh "yue -e #{path}.yue"
      tasks.clean!
    else
      sh "moon test/#{@n or ''}.moon"
