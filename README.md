# Alfons 5

<a href="https://discord.gg/3KGDznrEjC"><img src="https://img.shields.io/static/v1?label=discord&message=chat&color=brightgreen&style=flat-square"></a>
![GitHub stars](https://img.shields.io/github/stars/daelvn/alfons?style=flat-square)
![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/daelvn/alfons?include_prereleases&label=release&style=flat-square)
![LuaRocks](https://img.shields.io/luarocks/v/daelvn/alfons?style=flat-square)

<img align="left" width="128" height="128" src=".github/alfons-logo.svg">
<!-- <img src=".github/alfons-banner.png"> -->

> Alfons 5 is a rewrite of the original Alfons, written to be much more modular and usable. For the old Alfons 3, see the [`three`](https://github.com/daelvn/alfons/tree/three) GitHub branch.

Alfons is a task runner to help you manage your project. It's inspired by the worst use cases of Make (this means using `make` instead of shell scripts), it will read an Alfonsfile, extract the exported functions and run the tasks in order. I would tell you that there is no real reason to use this thing, but it's becoming surprisingly useful, so actually try it out.

> [!TIP]
> Check out the 5.2 update!
> Shell autocompletions, help messages, Taskfile documentations and extra environment functions have been added.

## Table of contents

- [Alfons 5](#alfons-5)
  - [Table of contents](#table-of-contents)
  - [Changelog](#changelog)
    - [5.3](#53)
    - [5.2](#52)
    - [5](#5)
    - [4.4](#44)
    - [4.3](#43)
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
  - [Projects using Alfons](#projects-using-alfons)
  - [License](#license)
  - [Goodbye?](#goodbye)

## Changelog

### 5.3

- **5.3.1** (02.09.2024) Fixed argument parser bug. `alfons --a --b` is now `a = true; b = true` instead of `a = "--b"`.
- **5.3** (09.08.2024) Added [Yuescript](https://yuescript.org) support. Added a few functions.

- **Yuescript support.** You can now use `Alfons.yue` files (or any taskfile that ends in `.yue`) to load in Yuescript tasks.
- **Additions to the environment.**
  - `values`: Get the values of a table as an array
  - `entries`: Turns a table into an array of key-value tuples
  - `fromEntries`: Reverses the process of `entries`

### 5.2

- **5.2.2** (09.08.2024) Fixed the `reduce` implementation
- **5.2** (08.06.2024) Implemented Taskfile documentation, help messages and autocompletion

- **Taskfile documentation.** You can now document your Taskfiles for automatic help messages and shell completion.
  - Check [the documentation](docs/documenting.md) for more info.
- **Help messages.** You can now display a help message with `--help`, or even get help for a specific task with `--help [task]`.
  - This help message can be automatically generated from the detected tasks in the Taskfile.
  - It works best when you document your Taskfile, so you can add descriptions and options.
- **Shell autocompletion.** Shell autocompletion is now available in Zsh, Bash and Fish flavors.
  - The Zsh and Fish flavors are by far the most complete, since Zsh's and Fish's completion systems are slightly more capable.
  - Bash is only able to list tasks, and sometimes options or flags for those tasks. Use Zsh.
  - Check [the documentation](docs/autocompletion.md) for more info and install instructions.
- **Additions to the environment.**
  - `lines`: Split a string into lines
  - `split`: Split any string by any pattern
  - `sanitize`: Neutralizes pattern magic characters in strings
  - `keys`: Get the keys of a table as an array
  - `slice`: Creates a slice of an array
  - `map`, `reduce`, `filter` do to arrays what you would expect
  - `contains` has been rewritten

### 5

- **5.0.2** (23.01.2023) Rolled back test mode
- **5.0.1** (23.01.2023) Fixed rockspec dependencies
- **5.0** (23.01.2023) Switched out [filekit](https://github.com/daelvn/filekit) in favor of [lpath](https://github.com/starwing/lpath).

I am back to life and filekit errored on me. Filekit is terribly inefficient anyway and I don't know why I ever made it. Now I am using an actually good filesystem library. It's a breaking change, though.

- **Compatibility with ComputerCraft has been removed.** Alfons 5 is not compatible with it.
- **Replaced filekit with lpath**
  - `fs` in the environment no longer points to `filekit`, but to `path.fs`
  - `path`, `fsinfo` and `env` have been added to the environment, corresponding to `path`, `path.info` and `path.env` respectively.
- Additions to the environment
  - `safeOpen`: Open IO handles safely
  - `listAll`: Returns a list of all files and directories recursively.
  - `copy`: Recursive file copy
  - `delete`: Recursive delete
  - `isEmpty`: Checks if a directory is empty
- Changes to the environment
  - All FS operations don't deal in absolute paths anymore
  - `wildcard` and `iwildcard` may exhibit slightly different behavior.

### 4.4

- **4.4** (04.02.2021) Added [`exists`](docs/environment.md) and **Experimental Teal Support**.

Some critical bugs in the loading of taskfiles and the invocation of tasks have been fixed.

### 4.3

- **4.3** (26.01.2021) Added [`calls`](docs/arguments.md#calls) and [`npairs`](docs/provide.md#npairs).

### 4.2

- **4.2** (02.10.2020) Internal overhaul.

Alfons 4.2 changes the whole way that Alfons works on the inside. Please refer to [Loading](docs/loading.md) and [API](docs/api.md) for the most notable work.

### 4.1

- **4.1.4** (12.09.2020) - Bugfix on `default` task.
- **4.1.3** (11.09.2020) - Funny Homestuck Number update. Fix `inotify` dependency.
- **4.1.2** (29.08.2020) - More bugfixes
- **4.1.1** (27.08.2020) - Bugfixes
- **4.1** (27.08.2020) - Added [`uses`](docs/arguments.md)

## Usage

Run `alfons` in a directory with an `Alfons.lua` or `Alfons.moon` file. Using MoonScript (obviously) requires installing MoonScript via LuaRocks.

To see the documentation, check out the [`docs/`](docs/) folder of this repo.

To get started using Alfons, check out the [Tutorial](docs/tutorial.md) or the [Recipes](docs/recipes.md).

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

```lua
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

## Projects using Alfons

- [Moonbuild](https://github.com/natnat-mc/moonbuild) by the one and only [Codinget](https://github.com/natnat-mc)
- [awlua](https://github.com/Le0Developer/awluas) by [Le0Developer](https://github.com/Le0Developer)
- [VNDS-LOVE](https://github.com/ajusa/VNDS-LOVE) by [ajusa](https://github.com/ajusa)

Thanks for using the project \<3.

## License

Throwing it to the public domain. Check out the [license](https://github.com/daelvn/alfons/blob/rewrite/LICENSE.md).

## Goodbye?

goodbye.
