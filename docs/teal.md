# Teal support

> **WARNING:** Teal support is **experimental** and relies on the Teal Compiler API that is subject to change. Use this at your own risk. It may be deprecated at any moment.

## Taskfiles

Taskfiles can be written in Teal, and you can use an `Alfons.tl` file just as you would an `Alfons.lua` or an `Alfons.moon` file. You may have some trouble with `tl check` warning you about unknown variables like `tasks` or `store`, as well as the many functions that are not specified as types. Teal support is **experimental** and it will still take time to accomodate Alfons to the type system.

### Defining a taskfile

While you can just define it as a Lua taskfile, feel free to use this template if you really, really care about types. Remember that you must declare your functions as globals!

```lua
-- This definition is optional. Feel free to use `self:table`
-- instead.
-- If you are from the Teal team, and know how to include this
-- type automatically, let me know!
local record Self
  metamethod __index: {string:any}
  name: string
  task: function -- it takes nothing and returns nothing
end

global function always(self:Self)
  print(self.name)
end
```

## Teal plugin

The `alfons-teal` rock (included in this repo but installed separately) provides a `teal` plugin that you can use via `load` (see more [here](loading.md)). The functionality for that plugin is described here.

This plugin exports the following commands, which you should not overwrite: **`install`, `build`, `watch`**.

### Installing LuaRocks dependencies

> **WARNING:** LuaRocks does **not** have an official updated API, so this task resorts to running `sh "luarocks install dependency"`. LuaRocks must therefore be a command available in your PATH. If you are a LuaRocks developer and know how to fix this, PRs welcome!

Upon loading Teal, it will install all dependencies from `store.dependencies`, which must be a list of strings, each a valid LuaRocks package. You can turn off this feature by doing `store.install = false`, and then later installing the dependencies by running the `install` task.

```lua
store.dependencies = {"tl", "busted"}

global function always()
  load "teal"
end
```

### Hooks

The `teal` plugin can run several kinds of hooks:

- Pre-install (`teal_preinstall`)
- Post-install (`teal_postinstall`)
- Pre-build (`teal_prebuild`)
- Post-build (`teal_postbuild`)

Simply define these tasks, and they will be run accordingly!

### Downloading typings.

The `alfons-teal` can automatically down