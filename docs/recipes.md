# Recipes

## Amalg.lua

Requires [amalg.lua](rockbuild -m -t #{@v} u)

### Pack

```lua
function pack(self)
  show("Packing using amalg.lua")
  -- options
  self.o = self.o or self.output or "out.lua"
  self.s = self.s or self.entry  or "src/main.lua"
  -- collect modules
  local modules = {}
  for file in wildcard "src/*.lua" do modules[#modules+1] = "src." .. filename(file) end
  -- pack
  sh("amalg.lua -o " .. self.o .. " -s " .. self.s .. " " .. table.concat(modules, " "))
```

```moon
pack: =>
  show "Packing using amalg.lua"
  @o    or= @output or "alfons.lua"
  @s    or= @entry or "bin/alfons.lua"
  modules = for file in wildcard "alfons/*.moon" do "alfons.#{filename file}"
  sh "amalg.lua -o #{@o} -s #{@s} #{table.concat modules, ' '}"
```

## Rockbuild

Requires [rockbuild](https://github.com/daelvn/rockbuild)

### Make

```lua
function make(self)
  if self.v
    sh("rockbuild -m --delete " .. v)
  end
end
```

### Release

```lua
function release(self)
  if self.v
    sh("rockbuild -m -t " .. v .. " u")
  end
end
```

## MoonScript

### Compile

```moon
compile: => for file in wildcard "**.moon"
  sh "moonc #{file}" unless file == "Alfons.moon"
```

### Build

```moon
build: => build (wildcard "**.moon"), (file) -> sh "moonc #{file}"
```

### Watch

Requires `inotify` LuaRocks package.

```moon
-- WATCH dirs, exclude, mode, match, process
watch: => watch {"."}, {".git"}, "live", (glob "*.moon"), (file, ev) -> sh "moonc #{file}"
```

### Clean

```moon
clean: => delete file for file in wildcard "**.lua"
```
