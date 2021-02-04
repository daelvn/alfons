# Teal support

> **WARNING:** Teal support is **experimental** and relies on the Teal Compiler API that is subject to change. Use this at your own risk. It may be deprecated at any moment. To use, install the `tl` rock.

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

This plugin exports the following commands, which you should not overwrite: **`install`, `build`, `watch`, `typings`**.

### Installing LuaRocks dependencies

> **WARNING:** LuaRocks does **not** have an official updated API, so this task resorts to running `sh "luarocks install dependency"`. LuaRocks must therefore be a command available in your PATH. If you are a LuaRocks developer and know how to fix this, PRs welcome!

Upon loading Teal, it will install all dependencies from `store.dependencies`, which must be a list of strings, each a valid LuaRocks package. You can turn off this feature by doing `store.install = false`, and then later installing the dependencies by running the `install` task.

```lua
store.dependencies = {"tl", "busted"}

global function always()
  load "teal"
end
```

### Building

The `build` task is simply a wrapper for `tl build`, since I figured that implementing this as an Alfons plugin would be way overkill.

### Hooks

The `teal` plugin can run several kinds of hooks:

- Pre-install (`teal_preinstall`)
- Post-install (`teal_postinstall`)
- Pre-build (`teal_prebuild`)
- Post-build (`teal_postbuild`)

Simply define these tasks, and they will be run accordingly!

### Downloading typings.

> **WARNING:** This task requires the `dkjson` and `http` packages, which you must install before using this. Otherwise, there would be no way of fetching the content.

The `alfons-teal` can download type definitions from the [teal-types](//github.com/teal-language/teal-types) repository and into your current working directory, using the `typings` task.

### CLI

You can do this from the CLI by just loading the `teal` plugin and doing:

```
$ alfons typings -m <rock>
```

### Taskfile

When you load the plugin, it will automatically try to use `store.typings` (a list of strings) as a source for what rocks to fetch type definitions for. You can turn off this behavior by setting `store.install` to `false`, and then running it later like this:

```lua
-- Lua
tasks.typings{ modules = {"..."} }
-- MoonScript
tasks.typings modules: {"..."}
```

## Showcase

This is a short "tutorial" on how to use the `teal` plugin.

### Installing

