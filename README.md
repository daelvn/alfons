# Alfons
Alfons is a small script that will help you with your project management! Inspired by the worst use cases of Make (so basically, using targets instead of shell scripts), it will read an `Alfons` file, extract the exported functions and run the tasks just like `alfons <task>`.

## CLI Usage
You can call tasks using the command-line tool. Simply pass the task name as an argument. Any `-` will get replaced by `_`,and every `/` by `_` as well, to enable writing Taskfiles easily. Any argument that is not a recognized task will be added as an extra argument. These do not need to be prefixed.
```
# Calling a list of recognized tasks
alfons task1 task2 task3
```
Unrecognized arguments will get accumulated and passed to the next known task:
```
alfons arg1 arg2 task1 arg3 task2
# Results in task1(arg1, arg2) and task2(arg3)
```

## Taskfiles
The taskfiles that Alfons is able to read must have specific names. These include:
- `Alfons`
- `alfons`
- `Alfonsfile`
- `alfonsfile`
- `Taskfile`
- `taskfile`
- `Alfons.moon`
- `Alfons.lua`
- `alfons.lua`
These all are checked in the same order displayed here. Note that there is no `alfons.moon` file, this is because the source filename is called like this, and development is much easier when you dont have to change the name to this file. There are some filenames that don't have an extension, these must, obligatorily, have a comment inside that indicates the file type. This comment must match the regex `\-\- alfons: ?[a-z]+`, and the optins availiable are either "lua" or "moon". This means that your comment can be any of:
```
-- alfons: moon
-- alfons: lua
-- alfons:moon
-- alfons:lua
```

## Writing tasks
Tasks must be exported/global functions in your taskfile, they will be loaded into a table by Alfons. It does not get loaded into the global environment, but into a custom environment which is then captured. All functions are passed the self/@ argument. This arguments includes a `name` field (the name with which it was called), an `argl` field with the extra arguments, `ltext` as the [ltext](https://github.com/daelvn/ltext) library, and `file` as the `file.lua` module in this repo.

## Callback tasks
There are some tasks which are called at special times:
- The `always` task runs always before any other task.
- The `default` task runs if no other task has been run.
- The `teardown` task runs always after every task.
These all get passed arguments the same way any other task would.

## Writing AKA-style aliases
You can write AKA-style aliases by using the `/` replacement, and writing them "plainly" in your Taskfile.
```moon
-- Let's try to write an alias for diversity/docker/compose
-- alfons: moon
diversity:
  docker:
    compose: do export diversity_docker_compose = =>
```
This abuse of MoonScript's syntax is unnecessary, but could look more organized in bigger alias files. You can just simply export as another task.

## Installing
You can use LuaRocks to install this
```
$ luarocks install alfons
```
It works on both 5.1 and 5.3!
