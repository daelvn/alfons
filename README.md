# Alfons
Alfons is a small script that will help you with your project management! Inspired by the worst use cases of Make (so basically, using targets instead of shell scripts), it will read an `Alfons` file, extract the exported functions and run the tasks just like `alfons <task>`.

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

Returns everything but the extension of a file

#### extension

Returns only the extension of a file without the dot.

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

##### publish-rockspec

```moon
(pkg, message="Release", prefix="v", source="origin", branch="master") -> (ver) =>
  git.tag  "-a #{prefix}#{ver} -m '#{message} #{ver}'"
  git.push "#{source} #{branch} --tags"
  sh "luarocks upload #{pkg}-#{ver}-1.rockspec"
  for file in wildcard "*.rock" do fs.delete file
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
  :print
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
  -- own
  :cmd, sh: cmd
  :env
  :wildcard, :basename, :extension
  :moonc, :git
  :get, :clone
}
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