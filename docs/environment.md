# Environment

This is the environment being passed to Alfonsfiles, along with everything on `provide`.

```moon
ENVIRONMENT = {
  :_VERSION
  :assert, :error, :pcall, :xpcall
  :tonumber, :tostring
  :select, :type, :pairs, :ipairs, :next, :unpack
  :require
  :print, :style                        -- from ansikit
  :io, :math, :string, :table, :os, :fs -- fs is either CC/fs or filekit
}
```

## Accessing tasks

Any defined task can be called using the `tasks` table. Just do `task.name!` to call it or pass a table if you want to use arguments. You can access any task, anywhere; it is allowed to call tasks from taskfiles you included, and those taskfiles will be able to use tasks of the parent taskfile. Metatable magic is used to that "local" tasks are always preferred over tasks from other taskfiles.

## Store

`store` is a table shared across all tables that you can use to pass data to other taskfiles or generally just create configuration fields.