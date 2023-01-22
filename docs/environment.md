# Environment

This is the environment being passed to Alfonsfiles, along with everything on `provide`.

```moon
-- environment for alfons files
ENVIRONMENT = {
  :_VERSION
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os
  :fs                                   -- fs is either CC/fs or lpath.fs
  :path, :env, :fsinfo                  -- lpath, lpath.env and lpath.info respectively
}
```

## Accessing tasks

Any defined task can be called using the `tasks` table. Just do `task.name!` to call it or pass a table if you want to use arguments. You can access any task, anywhere; it is allowed to call tasks from taskfiles you included, and those taskfiles will be able to use tasks of the parent taskfile. Metatable magic is used to that "local" tasks are always preferred over tasks from other taskfiles.

You can check if a task exists by using the `exists` function, that takes a string (the requested task name).

### Global tasks

The `tasks` table can only access tasks that are at the same level or below it (subtasks). Because of how Alfons' internals work, it is possible to access higher tasks. As of 4.4, you can do this via the magic table `gtasks`. It appears to be empty, but indexing it will return the first task that has the same name. To check if a task exists globally, use `gexists` (takes a string, the requested task name).

```moon
tasks:
  always: => gtasks.example!
```

## Store

`store` is a table shared across all tables that you can use to pass data to other taskfiles or generally just create configuration fields.

### Callstack

Starting in Alfons 4.3, a new predefined field in `store` named `callstack` contains a stack of the currently executing functions. Peeking the stack (`store.callstack[#store.callstack]`) will return the function that is currently being executed, and should be equivalent to `@name`. This was necessary to implement [`calls`](docs/provide.md#calls).
