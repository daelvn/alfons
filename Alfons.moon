tasks:
  make:    => sh "rockbuild -m --delete #{@v}"
  release: => sh "rockbuild -m -t #{@v} u"
  -- compile everything
  compile: =>
    sh "moonc #{file}" for file in wildcard "alfons/**.moon"
    sh "moonc bin/alfons.moon"
  -- clean everything
  clean: =>
    show "Cleaning files"
    for file in wildcard "**.lua"
      continue if (file\match "alfons.lua") and not (file\match "bin")
      fs.delete file
  -- use amalg to pack Alfons
  pack: =>
    show "Packing using amalg.lua"
    @o    or= @output or "alfons.lua"
    @s    or= @entry or "bin/alfons.lua"
    modules = for file in wildcard "alfons/*.moon" do "alfons.#{filename file}" 
    sh "amalg.lua -o #{@o} -s #{@s} #{table.concat modules, ' '}"
  -- test
  test: =>
    tasks.compile!
    tasks.pack!
    tasks.make v: "4.0"