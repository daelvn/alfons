# Alfons 4
<a href="https://discord.gg/Y75ZXrD"><img src="https://img.shields.io/static/v1?label=discord&message=chat&color=brightgreen&style=flat-square"></a> 
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/daelvn/alfons/CI?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/daelvn/alfons?style=flat-square)
![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/daelvn/alfons?include_prereleases&label=release&style=flat-square)
![LuaRocks](https://img.shields.io/luarocks/v/daelvn/alfons?style=flat-square)

<img align="left" width="128" height="128" src=".github/alfons-logo.svg">
<!-- <img src=".github/alfons-banner.png"> -->

> Alfons 4 is a rewrite of the original Alfons, written to be much more modular and usable. For the old Alfons 3, see the [`three`](https://github.com/daelvn/alfons/tree/three) GitHub branch.

Alfons is a task runner to help you manage your project. It's inspired by the worst use cases of Make (this means using `make` instead of shell scripts), it will read an Alfonsfile, extract the exported functions and run the tasks in order. I would tell you that there is no real reason to use this thing, but it's becoming surprisingly useful, so actually try it out.

## Table of contents
- [Alfons 4](#alfons-4)
  - [Table of contents](#table-of-contents)
  - [Changelog](#changelog)
    - [4.2](#42)
    - [4.1](#41)
  - [Usage](#usage)
    - [Defining tasks](#defining-tasks)
    - [Calling tasks](#calling-tasks)
    - [Arguments](#arguments)
    - [Migrating from Alfons 3](#migrating-from-alfons-3)
      - [Missing functions](#missing-functions)
      - [Importable tasks](#importable-tasks)
  - [Installing](#installing)
    - [Extra features](#extra-features)
  - [License](#license)
  - [Goodbye?](#goodbye)

## Changelog

### 4.2

- **4.2** (02.10.2020) Internal overhaul.

Alfons 4.2 changes the whole way that Alfons works on the inside.

### 4.1

- **4.1.4** (12.09.2020) - Bugfix on `default` task.
- **4.1.3** (11.09.2020) - Funny Homestuck Number update. Fix `inotify` dependency.
- **4.1.2** (29.08.2020) - More bugfixes
- **4.1.1** (27.08.2020) - Bugfixes
- **4.1** (27.08.2020) - Added [`uses`](docs/arguments.md)

## Usage

Run `alfons` in a directory with an `Alfons.lua` or `Alfons.moon` file. Using MoonScript (obviously) requires installing MoonScript via LuaRocks.

To see the documentation, check out the [`docs/`](docs/) folder of this repo.

### Defining tasks

Tasks are obtained by either returning a table `{tasks={}}` where the empty table is a list of named functions, or by exporting globals. The preferred mode for Lua is exporting globals, and the preferred mode for MoonScript is returning a table, although both work in both languages.

**Lua:**

```lua
-- Exporting globals
function always(self) print(self.name) end
-- Returning table
return { tasks = {
  always = function(self) print(self.name) end
}}
```

**MoonScript**

```moon
-- Exporting globals
export always ==> print @name
-- Returning table
tasks:
  always: => @name
```

### Calling tasks

From the command line, simply pass the name of the task you wish to run. Alternatively, use `tasks.TASK` to call `TASK` if it's loaded.

**Lua:**

```
function test (self)
  print("I am " .. self.name .. " and " .. self.caller .. " called me.")
end

function call (self)
  tasks.test{caller = self.name}
end
```

**MoonScript:**

```moon
tasks:
  test: => print "I am #{@name} and #{@caller} called me."
  call: => tasks.test caller: @name
```

### Arguments

Arguments are passed in the `self` table of every function, which contains a field called `name` which is, well, uh, its own name. You can also use the `args` table to see the whole tree of arguments. Feel free to play with and abuse this!

### Migrating from Alfons 3

Some functions are either not implemented or not yet ported.

#### Missing functions

`moonc`, `git`, `clone` and `toflags` do not exist anymore. The first three may be implemented at a later time, and the last won't be implemented due to the changes in Alfons' argument system. For now, you will have to use their command-line counterparts, so `moonc file` becomes `sh "moonc #{file}"` and such.

#### Importable tasks

`fetch`/`fetchs` is now just `fetch`, and `ms-compile` has been removed and will probably not come back. Write a compile task manually. This should work as a dropin replacement:

**Lua:**
```lua
compile = function()
  for file in wildcard "**.moon" do sh "moonc ".. file end
end
```

**MoonScript:**
```moon
compile: => sh "moonc #{file}" for file in wildcard "**.moon"
```

## Installing

~~Since this is not upstream yet, you can't install through the LuaRocks server. However, you can install Alfons using itself.~~

Alfons 4 is now available on LuaRocks!

```sh
$ luarocks install alfons
```

### Extra features

The preincluded task `fetch` depends on [lua-http](https://github.com/daurnimator/lua-http) to be used. The `watch` function depends on [linotify](https://github.com/hoelzro/linotify) and will not work on platforms other than Linux.

```sh
$ luarocks install http     # lua-http
$ luarocks install inotify  # linotify
```

## License

Throwing it to the public domain. Check out the [license](https://github.com/daelvn/alfons/blob/rewrite/LICENSE.md).

## Goodbye?

goodbye.