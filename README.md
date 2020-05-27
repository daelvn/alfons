# Alfons
Alfons is a small script that will help you with your project management! Inspired by the worst use cases of Make (so basically, using targets instead of shell scripts), it will read an `Alfons` file, extract the exported functions and run the tasks just like `alfons <task>`.

## Table of contents

- [Alfons](#alfons)
  - [Table of contents](#table-of-contents)
  - [Changelog](#changelog)
  - [Usage](#usage)
    - [Arguments](#arguments)
    - [Flags](#flags)
  - [Installing](#installing)
  - [Taskfiles](#taskfiles)
    - [Helper functions](#helper-functions)
      - [cmd](#cmd)
      - [cmdfail](#cmdfail)
      - [env](#env)
      - [moonc](#moonc)
      - [wildcard](#wildcard)
      - [basename](#basename)
      - [extension](#extension)
      - [filename](#filename)
      - [git](#git)
      - [clone](#clone)
      - [get](#get)
      - [toflags](#toflags)
      - [readfile](#readfile)
      - [writefile](#writefile)
      - [style](#style)
    - [Importable tasks](#importable-tasks)
        - [fetch](#fetch)
        - [ms-compile](#ms-compile)
    - [Environment](#environment)
    - [As a build system](#as-a-build-system)
    - [Defining tasks](#defining-tasks)
      - [Lua](#lua)
      - [MoonScript](#moonscript)
    - [Calling tasks](#calling-tasks)
      - [Lua](#lua-1)
      - [MoonScript](#moonscript-1)
    - [Arguments](#arguments-1)
  - [License](#license)

## Changelog

- **3.8** - Added `cmdfail`.
- **3.7** - Deprecating `publish-rockspec`. Added `fetch` task.
- **3.6** - Added `filename` function.
- **3.5.2** - Tasks are now checked to be functions.
- **3.5.1** - `style` from [ansikit](https://github.com/daelvn/ansikit) is now available in the environment.
- **3.5** - You can now reference other tasks with `tasks.TASKNAME`.
- **3.4.1** - Added `build`, `readfile`, `writefile` and `toflags`
- **3.4** - Switched to [Rockbuild](https://github.com/daelvn/rockbuild) for rockspec publishing.
- **3.3.1** - `clone` now allows for a destination folder.
- **3.3** - Added `clone`.
- **3.2** - Added importable tasks.

## Usage

Simply call `alfons` in a directory with an `Alfons.lua` or `Alfons.moon` file (Note: `.moon` loading requires to install MoonScript).

### Arguments

Arguments behave a bit weirdly. Basically, if an argument is a recognized task, it will be run with all arguments in front being passed, otherwise nothing happens. Let's take this sample `Alfons.lua`:

```lua
function task1 (self, ...)
  arg = {...}
  for _, v in ipairs arg do print (v) end
end

function task2 (self, ...)
  arg = {...}
  for _, v in ipairs arg do print (v) end
end
```

Now, let's run it and check our output:

```sh
$ alfons task1 a b task2 c d
# what task1 prints
a
b
task2
c
d
# what task2 prints
c
d
```

Hope this clarifies things!

### Flags

Alfons 3.4 introduces a new `toflags` function that turns the varargs in your tasks into flags, such as:

```moon
tasks:
  example: (...) =>
    flags = toflags ...
    print "hello!" if flags.sayhello
```

And then:

```sh
$ alfons example sayhello
Alfons 3.4
Using alfons.moon
-> example
hello!
```

## Installing

```sh
$ luarocks install alfons
```

## Taskfiles

Taskfiles are `Alfons.lua` or `Alfons.moon` files that contain the tasks that are recognized and run.

### Helper functions

Several helper functions are provided: 

#### cmd

`cmd`/`sh` as an alias to `os.execute`.

#### cmdfail

`cmdfail`/`shfail` is a wrapper around `os.execute` that will exit the program with the code returned by `os.execute` if it is not 0. For example, trying to run a program that does not exist will exit alfons with code 127.

#### env

If you run Alfons as:

```sh
$ TEST=5 alfons
```

You can access `TEST` by using `env.TEST`.

#### moonc

Takes an input (`moonc #{input}`) and optionally an output (`moonc -o #{output} #{input}`)

#### wildcard

Iterable globbing that lets you do things such as:

```moon
compileall: =>
  for file in wildcard "*.moon"
    moonc file
```

#### basename

Returns everything but the extension of a file.

#### extension

Returns only the extension of a file without the dot.

#### filename

Returns only the filename without extension and parent path. `/home/daelvn/test.txt` becomes `test`. Only available starting from version 3.6+

#### git

`git.command "a", "o"` translates to running `git command a o`.

#### clone

Clones a repository from GitHub over HTTPS.

`clone "daelvn/alfons"` translates to running `git clone https://github.com/daelvn/alfons.git`.

Optionally takes a destination folder.

#### get

`get (name)` imports `alfons.tasks.name` with the proper Alfons environment. To create your own, simple make a LuaRocks package that exports to `alfons.tasks.<task>`. Use it as:

```lua
always = get "task"
```

```moon
tasks:
  always: get "task"
```

These modules simply return a function, nothing more to it, really.

#### toflags

Turns varargs into flags. See above.

#### readfile

Takes a filename and returns its contents.

#### writefile

Takes a filename and a string, and writes the string to it.

#### style

As it is imported/defined from Alfons, it is now available to the environment. You can now use the [`style` function from Ansikit](https://git.daelvn.com/ansikit/module/style/#style) in Alfons.

```moon
tasks
  pretty: => print "%{blue}#{@name}"
```

### Importable tasks

These are tasks that can be imported with `get "task"`.

##### fetch

`fetch` will return the contents of a URL over HTTP. It uses the HTTP API on ComputerCraft, and LuaSocket on every other platform. To install LuaSocket, you can simply do:

```sh
$ luarocks install luasocket
```

The task gets an URL, and simply returns the contents as a string:

```lua
fetch = get "fetch"

function printurl (self)
  print(tasks.fetch("https://example.com"))
end
```

```moon
tasks:
  fetch:    get "fetch"
  printurl: => print tasks.fetch "https://example.com"
```

If you need to write the contents to a file, you can use `writefile`:

```lua
fetch = get "fetch"

function download (self, url, file)
  writefile(file, tasks.fetch(url))
end

function main (self)
  tasks.download("https://example.com", "index.html")
end
```

```moon
tasks:
  fetch:    get "fetch"
  download: (url, file) =>
    writefile file, tasks.fetch url
  main: =>
    tasks.download "https://example.com", "index.html"
```

##### ms-compile

```moon
=>
  for file in wildcard "**.moon"
    continue if file\match "Alfons%.moon"
    moonc file
```

### Environment

These Taskfiles have a limited environment, defined as such:

```moon
-- Environment for Alfons files
ENVIRONMENT = {
  :_VERSION, :_HOST
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
  -- own
  :toflags
  :readfile, :writefile
  :cmd, sh: cmd
  :env
  :wildcard, :basename, :extension
  :moonc, :git
  :get, :clone
  :build
}
```

### As a build system

Well, not really, but you can use Alfons as a really simple build system that will only compile the files you've modified. You do this via the 3.4 addition: `build`. You give it an iterator (`wildcard`), and a function. This function must take a filename and do whatever with it. It will iterate through all files and get their last modification time (and, if not created yet, will store them in `.alfons`). Then, it will compare the modification time with the old ones found on `.alfons`, produced by a previous run, and only use the function on the files which have been modified.

```moon
tasks:
  compile:
    build (wildcard "**.moon"), =>
      return if @match "Alfons.moon"
      moonc @
```

### Defining tasks

Tasks are obtained by either returning a table `{tasks: {}}` where the empty table is a list of named functions, or by exporting globals. The preferred mode for Lua is exporting globals, and the preferred mode for MoonScript is returning a table, although both work in both languages.

#### Lua

```lua
-- Exporting globals
function always(self) print(self.name) end
-- Returning table
return { tasks = {
  always = function(self) print(self.name) end
}}
```

#### MoonScript

```moon
-- Exporting globals
export always ==> print @name
-- Returning table
tasks:
  always: => @name
```

### Calling tasks

Starting from version 3.5, you can now use `tasks.TASK()` to call a task named `TASK`. I don't know why I didn't do this earlier, considering it was literally a one line change.

#### Lua

```lua
function test (self, caller)
  print("I am " .. self.name .. " and " .. caller .. " called me.")
end

function call (self)
  tasks.test(self.name)
end
```

#### MoonScript

```moon
tasks:
  test: (caller) => print "I am #{@name} and #{caller} called me."
  call:          => tasks.test @name
```

### Arguments

Although the whole Taskfile is passed the arguments, each individual function is passed other information. A general task will get the shape `function(self, ...) end`, where `self` only contains the field `name` for now, and the rest are CLI arguments.

## License

Using the [Unlicense](http://unlicense.org/).

```
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
```