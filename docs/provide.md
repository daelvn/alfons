# Functions

This is the documentation for the functions provided in the Alfons environment.

To see the documentation for `build` and `watch`, check out their respective markdown files.

## Table of Contents

- [Functions](#functions)
  - [Table of Contents](#table-of-contents)
  - [Tables](#tables)
    - [npairs](#npairs)
    - [env](#env)
    - [keys](#keys)
    - [values](#values)
    - [entries](#entries)
    - [fromEntries](#fromentries)
  - [Arrays](#arrays)
    - [map](#map)
    - [reduce](#reduce)
    - [filter](#filter)
    - [slice](#slice)
    - [contains](#contains)
  - [Strings](#strings)
    - [lines](#lines)
    - [split](#split)
    - [sanitize](#sanitize)
  - [IO](#io)
    - [prints](#prints)
    - [printError](#printerror)
    - [safeOpen](#safeopen)
    - [safePopen](#safepopen)
    - [readfile](#readfile)
    - [writefile](#writefile)
    - [serialize](#serialize)
    - [ask](#ask)
    - [show](#show)
    - [cmd](#cmd)
    - [cmdfail](#cmdfail)
    - [cmdread](#cmdread)
  - [FS](#fs)
    - [isEmpty](#isempty)
    - [delete](#delete)
    - [copy](#copy)
    - [wildcard](#wildcard)
    - [iwildcard](#iwildcard)
    - [listAll](#listall)
  - [Path](#path)
    - [basename](#basename)
    - [extension](#extension)
    - [filename](#filename)
    - [pathname](#pathname)
    - [load](#load)
    - [style](#style)
  - [Importable](#importable)
    - [fetch](#fetch)

## Tables

### npairs

Exactly like [ipairs](https://www.lua.org/manual/5.4/manual.html#pdf-ipairs), but it does not stop after a `nil` value.

### env

If you run Alfons as:

```sh
$ TEST=5 alfons
```

You can access `TEST` by using `env.TEST`.

### keys

`keys (table:{*:*}) -> [*]`

Returns all the keys in a table.

### values

`values (table:{*:*}) -> [*]`

Returns all the values in a table.

### entries

`entries (table:{*:*}) -> [{*,*}]`

Returns an array of `{key, value}` tuples made from the keys and values of a table.

### fromEntries

`fromEntries (entries:[{*,*}]) -> {*:*}`

Reverses the process of `entries`.

## Arrays

### map

`map (arr:[*], predicate:(value:*, key:*) -> *) -> [*]`

Maps over an array.

### reduce

`reduce (arr:[*], predicate:(accumulator:*, value:*) -> *, initial: *?) -> *`

Reduces an array to a single value using an accumulator. Equivalent to `foldl`.

### filter

`filter (arr:[*], predicate:(value:*, key: *) -> boolean) -> [*]`

Creates a new array with only the values that pass the predicate.

### slice

`slice (arr:[*], start:number?, end:number?) -> [*]`

Creates a slice of an array that starts at `start` and ends at `end`.

### contains

`contains (arr:[*], value:*) -> boolean`

Checks if an array contains a certain value.

## Strings

### lines

`lines (string) -> [string]`

Splits a string into lines.

### split

`split (str:string, re:string, plain:boolean, matches:number) -> [string]`

Splits a string `str` into parts by a pattern `re`, which is interpreted as a Lua pattern except if the `plain` flag is set to true. Additionally, a maximum number of matches can be set with the `matches` argument.

### sanitize

`sanitize (string) -> string`

Makes sure that a string is safe to use in patterns without magic characters.

## IO

### prints

`prints (...) -> nil`

`print` and `style` (from [ansikit](https://git.daelvn.com/ansikit)) together.

### printError

`printError (text:string) -> nil`

Prints a string in red.

### safeOpen

`safeOpen (file:string, mode:string) -> io | {["error"]:string}`

Returns a table with an error string if the file could not be opened properly.

### safePopen

`safePopen (command:string, mode:string) -> io | {["error"]:string}`

Equivalent to `safeOpen`, but for `io.popen`.

### readfile

`readfile (file:string) -> string`

Takes a filename and returns its contents.

### writefile

`writefile (file:string, content:string) -> nil`

Takes a filename and a string, and writes the string to it.

### serialize

`serialize (t:table) -> string`

Quick table serializing, not useful in most cases. Used in `build`.

### ask

`ask (str:string) -> string`

Gets input from the user, with a prompt (optionally styled).

### show

`show (str:string) -> nil`

Displays a message, but fancy.

### cmd

`cmd (str:string) -> number`

`cmd`/`sh` as an alias to `os.execute`.

### cmdfail

`cmdfail (str:string) -> nil`

`cmdfail`/`shfail` is a wrapper around `os.execute` that will exit the program with the code returned by `os.execute` if it is not 0. For example, trying to run a program that does not exist will exit alfons with code 127.

### cmdread

`cmdread (command:string) -> string`

`cmdread` uses `safePopen` (`io.popen`) to execute a command and return all of its output. If `popen` did not work, it returns the error as a string.

## FS

### isEmpty

`isEmpty (dir:string) -> boolean`

Checks if a directory is empty

### delete

`delete (path:string)`

Deletes a file or folder recursively.

### copy

`copy (fr:string, to:string)`

Copies a file or folder recursively.

### wildcard

`wildcard (path:string) -> function (iterator)`

Iterable globbing that lets you do things such as:

```moon
compileall: =>
  for file in wildcard "*.moon"
    sh "moonc #{file}"
```

### iwildcard

`iwildcard (paths:table) -> function (iterator)`

A wrapper around `wildcard`, that lets you use several globs.

```moon
seeall: =>
  for file in iwildcard {"*.moon", "*.lua"}
    sh "cat #{file}"
```

### listAll

`listAll (path:string) -> [string]`

Returns a list of all nodes in `path` recursively.

## Path

### basename

`basename   (file:string) -> string`

Returns everything but the extension of a file.

### extension

`extension  (file:string) -> string`

Returns only the extension of a file without the dot.

### filename

`filename   (file:string) -> string`

Returns only the filename without extension and parent path. `/home/daelvn/test.txt` becomes `test`.

### pathname

`pathname   (file:string) -> string`

Returns the parent path of a file or folder.

### load

`load (name)` imports tasks defined in `alfons.tasks.name` and lets you access them from the tasks table, so you can run them from the command line and from other tasks. You can create your own LuaRocks modules which export something as `alfons.tasks.*` to add custom tasks, or just create a local folder `alfons/tasks/` and it will load from them too.

Please look at [Loading](loading.md) for more detailed documentatin.

### style

As it is imported/defined from Alfons, it is now available to the environment. You can now use the [`style` function from Ansikit](https://git.daelvn.com/ansikit/module/style/#style) in Alfons.

```moon
tasks
  pretty: => print style "%{blue}#{@name}"
```

## Importable

These are tasks that can be imported with `load "task"`.

### fetch

`fetch` will return the contents of a URL over HTTP. It uses [lua-http](https://github.com/daurnimator/lua-http)

```sh
$ luarocks install http
```

The task gets an URL, and simply returns the contents as a string:

```lua
function always ()
  load "fetch"
end
function printurl (self)
  print(tasks.fetch{url="https://example.com"})
end
```

```moon
tasks:
  always:   => load "fetch"
  printurl: => print tasks.fetch url: "https://example.com"
```

If you need to write the contents to a file, you can use `writefile`:

```lua
function always ()
  load "fetch"
end
function download (self)
  writefile(self.file, tasks.fetch{url = self.url})
end
function main (self)
  tasks.download{url="https://example.com", file="index.html"}
end
```

```moon
tasks:
  always: =>
    load "fetch"
  download: =>
    writefile @file, tasks.fetch url: @url
  main: =>
    tasks.download url:"https://example.com", file: "index.html"
```
