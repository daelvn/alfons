# Alfons API

Starting with 4.2, Alfons provides an API to embed Alfons functionality in your programs.

## Contents
- [Alfons API](#alfons-api)
  - [Contents](#contents)
  - [Installation](#installation)
  - [alfons.env](#alfonsenv)
  - [alfons.file](#alfonsfile)
  - [alfons.getopt](#alfonsgetopt)
    - [Argument parsing](#argument-parsing)
  - [alfons.look](#alfonslook)
  - [alfons.provide](#alfonsprovide)
  - [alfons.setfenv](#alfonssetfenv)
  - [alfons.version](#alfonsversion)
  - [alfons.init](#alfonsinit)
    - [initEnv](#initenv)
    - [runString](#runstring)
    - [Understanding the global environment](#understanding-the-global-environment)
    - [Creating your own alfons clone](#creating-your-own-alfons-clone)
      - [Arguments](#arguments)
      - [Loading](#loading)
      - [Running](#running)
      - [Executing tasks](#executing-tasks)
      - [Finalize](#finalize)
      - [Finish](#finish)

## Installation

You need to install the development rock instead of the upstream one. For that, follow these steps:

```sh
# Clone project
$ git clone https://github.com/daelvn/alfons.git
# Install dependencies
$ luarocks install moonscript
$ luarocks install rockbuild
$ luarocks install amalg
# Create the runnable file
$ alfons produce
# Build the rockspec locally
$ rockbuild -f rock-dev.yml -m --delete 4.4 # or change the version if you want
```

If there is enough demand, I'll upload the dev rockspec to LuaRocks with every release in form of an `alfons-extra` package or similar.

The rock also installs optional dependencies for Alfons like `http` or `linotify`. If you do not wish to install them, feel free to edit the development rockframe.

## alfons.env

`alfons.env` provides the default environment table (`ENVIRONMENT`), which does not include the functions in `alfons.provide`, and a function called `loadEnv` which takes a string of Lua code and a table, and will load the Lua code with the table as its environment. This function uses different mechanisms on different versions, due to `loadstring` being deprecated.

## alfons.file

Contains just two functions, `readLua`, which takes a filename and returns its contents; and `readMoon`, which does the same, but compiling the file contents as MoonScript.

## alfons.getopt

Contains a single function, `getopt`, which takes a list of arguments, and returns a table of parsed options. 

### Argument parsing

See [arguments.md](arguments.md)

## alfons.look

`alfons.look` introduces a `require`-style module lookup function that instead of running them and returning its results, it returns the contents of the file. It returns a table with a function `makeLook`, which takes a package path (defaults to `package.path`) and returns a lookup function. This function takes a module name and returns the contents of the file found, or `nil` and an error otherwise.

## alfons.provide

`provide` includes all the helper functions used in Taskfiles.

See [Functions](provide.md).

## alfons.setfenv

Returns a function (not a table). The function is simply a reimplementation of setfenv for Lua 5.2+

## alfons.version

Returns a table with a field `VERSION` which contains the current Alfons version.

## alfons.init

Provides the main functions required to run a Taskfile.

### initEnv

`initEnv` takes a `run` function (see below), a base environment (defaults to `alfons.env`'s `ENVIRONMENT`), a private global environment table (referred to as `genv`), and a module name (defaults to `main`). It returns an environment ready to use in Taskfiles. This function is internal and should not really be used, so I will not explain it.

### runString

`runString` takes:

1. either a string of Lua code or a module to perform lookup on (using `alfons.look`) as its first argument.
2. Then it takes a base environment (defaults to `alfons.env`'s `ENVIRONMENT`)
3. A boolean flag `runAlways` which determines whether the `always` task should be run or not.
4. A numeric `child` argument (actually unused) that determines how deep into the loaded Taskfiles you are (defaults to `0` for the main file and increments for children taskfiles when `load` is called).
5. A `genv`, where the tasks for all modules are neatly stored. Although you can set a starting value for this table (defaults to an empty one), you will not be able to access it again (unless you create the table before passing it and store the reference).
6. A reverse queue `rqueue` that determines the order in which the `default`, `teardown` and `finalize` tasks should be run. This queue should be reversed before running each task in it.
7. A boolean value that determines whether to pretty-print errors or not.

It loads the contents of the Taskfile without executing it.

It returns either the environment table (for accessing tasks and `store`) if it was already loaded or a function for running the Taskfile with arguments. These arguments will be processed by `alfons.getopt`.

The function returned adds the `args` function to the environment, local to each taskfile. It also adds the function `uses`, for checking the argument list for commands.

It runs the Alfons file and loads all tasks to `env.tasks`, where `env` represents the environment table. It wraps all tasks in a `run` function, which essentially pre-passes the name of the task (`@name`), and the task itself (`@task`).

It also adds the `load` function to load taskfiles inside taskfiles.

It runs the `always` task if the `runAlways` argument is enabled (defaults to `true`).

Then it adds a trigger to run the `default` and `finalize` tasks.

Finally, it returns the environment of the taskfile. It looks something like this, irrelevant parts skipped for convenience. These are the only things you will need to know.

```lua
env = {
  tasks = {},               -- table to access all tasks
  store = {},               -- global storage
  finalize = function() end -- calls the `default` and `finalize` tasks.
}
```

### Understanding the global environment

In the last section we mentioned `genv` and how you could initially set its value but not access it later. Lets look at its structure.

```lua
genv = {
  ["main"]  = {} -- this is main's environment
  ["fetch"] = {} -- environment for a subtaskfile
}
<metatable> = {
  store = {} -- global storage is here
}
```

Task lookup in the `env.tasks` table happens by looking at all the loaded taskfiles in `genv`. By adding more fields to `genv` initially, you can pre-load taskfiles without really loading them.

The global storage is in `genv`'s metatable, which you can also preload values at.

### Creating your own alfons clone

`bin/alfons.moon` is written in just a few lines of code, let's write a simplified version of it:

#### Arguments

First, lets get the list of tasks that we should run:

```moon
import getopt from require "alfons.getopt"
args = getopt {...}
```

#### Loading

The official program supports custom taskfile locations, but for the sake of simplicity, we'll skip that and only allow loading `Alfons.lua`.

```moon
import readLua from require "alfons.file"
content, contentErr = readLua "Alfons.lua"
unless content then error contentErr
```

#### Running

This is a straightforward step to get the environment.

```moon
import runString from require "alfons.init"
alfons, alfonsErr = runString content
unless alfons then error alfonsErr
env = alfons ...
```

#### Executing tasks

Now we need to run the tasks we have been asked for, with their respective arguments, and run `teardown` after each of them.

```moon
for command in *args.commands
  env.tasks[command] args[command] if env.tasks[command]
  (rawget env.tasks, "teardown")   if rawget env.tasks, "teardown"
```

#### Finalize

Finally, simply call the trigger to run `default` tasks if no other task in each taskfile has been run, and `finalize` tasks.

```moon
env.finalize!
```

#### Finish

And just like that, we have implemented Alfons! It is a pretty simple tool, despite the looks of it, really.