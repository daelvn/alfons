# Alfons
Alfons is a small script that will help you with your project management! Inspired by the worst use cases of Make (so basically, using targets instead of shell scripts), it will read an `Alfons` file, extract the exported functions and run the tasks just like `alfons <task>`.

## Writing tasks
```moon
-- Alfons
--================
-- alfons: moon
-- The header above is very important, although it can be placed anywhere as a comment. It can be either "moon" or "lua".
-- This is only necessary if your file doesn't have an extension.
export task = =>
  print @.ltext.title "Hello from this #{@.name}!"
  --> Hello from this task!
```

## Running tasks
This is very simple, just run `alfons [task [task [task [task ...]]]]` wherever your Alfonsfile is located.
