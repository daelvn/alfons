# Arguments

Arguments can be a bit weird due to the nature of tasks. This is different from how it used to be in Alfons 3.

Arguments that do not start with a hyphen (`-`) will be considered to be tasks to run. Every task will get its own set of arguments, passed after the task was called. Options in the format `-x` will be set as `{x = <next argument>}`. Flags in the format `-ab` will be set as `{a = true, b = true}`. Options in the format `--abc` will be set as `{abc = <next argument>}`.

Let's see this with an example. This is our Alfonsfile:

**MoonScript**

```moon
tasks:
  first:  => print @a
  second: => print @b
```

**Lua**

```lua
function first(self) print(self.a) end
function second(self) print(self.b) end
```

And if we call it like this, we will get the following output:

```sh
$ alfons first -a Hello second -b World!
Hello
World!
```

The tasks don't have access to other tasks' arguments in their `self` variable. However, you can access the whole argument table with `args`. This makes the following snippet equivalent.

**MoonScript**

```moon
tasks:
  first:  => print args.first.a
  second: => print args.second.b
```

**Lua**

```lua
function first(self) print(args.first.a) end
function second(self) print(args.second.b) end
```

## Uses

When running from the command line, a new function is provided (`uses`) that is effectively a shortcut for `contains args.commands, "task"`. It will check if another task was called. The task does not have to exist. You can use this for "subtasks", like `alfons docs serve`, instead of having to do `alfons docs --serve`, which is considerably *uglier*.

**MoonScript**

```moon
tasks:
  task: =>
    if uses "subtask"
      print "subtask was called!"
```

**Lua**

```lua
function task()
  if uses "subtask" then
    print "subtask was called!"
  end
end
```

**Result**

```
$ alfons task subtask
subtask was called!
```