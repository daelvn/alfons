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

## Argument parsing

Using `getopt`, you get a table `args` which contains the following information:

### Commands

Commands are the tasks to be executed in Alfons. They can be found at the following places:

`getopt {"task1"}` or `alfons task1`

```lua
args = {
  task1    = {},         -- task arguments go here, name of field varies.
  commands = { "task1" } -- in order of use.
}
```

### Flags

Flags are arguments without a value. They are all set to `true`.

`getopt {"task", "-a"}` or `alfons task -a`

```lua
args = {
  task = {
    ["a"] = true
  },
  commands = { "task" }
}
```

### Options

Options are arguments with a value. They are all set to their value.

`getopt {"task", "--opt", "value"}` or `getopt {"task", "--opt=value"}` or `alfons task --opt value` or `alfons task --opt=value`

```lua
args = {
  task = {
    ["opt"] = "value"
  },
  commands = { "task" }
}
```

### Interpreting arguments

- `--` alone passes the arguments that come after it as they are.
- `x` will be treated as a **command** and all arguments after it are arguments to it.
- `-x` will be paired with the argument after it as an **option** unless it is last in the list, in which case it is just a **flag**.
- `-abc` represents three **flags**: `a`, `b` and `c`.
- `--xa` will be paired with the next argument as an **option** unless it is last in the list, in which case it is just a **flag**.
- `--xa=val` uses `val` as a value to an **option** `xa`.