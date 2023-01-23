# Alfons for The Inexperienced Alfonsnsner

Hello, traveller! In this tutorial, I will be assuming this is your first time using Alfons. I will make it as easy to follow as possible. Put on your best programming socks and follow me into this deep abyss that Alfons represents.

- [Alfons for The Inexperienced Alfonsnsner](#alfons-for-the-inexperienced-alfonsnsner)
  - [Installing](#installing)
  - [Familiarizing with the interface](#familiarizing-with-the-interface)
  - [Taskfiles](#taskfiles)
  - [Two tasks?!?!?!](#two-tasks)
  - [Introspection](#introspection)
  - [Task arguments](#task-arguments)
  - [Calling other tasks](#calling-other-tasks)
  - [Storing data](#storing-data)
  - [Exploring](#exploring)

## Installing

The proper way of installing Alfons is through LuaRocks. If you're on Linux, you're smart enough to know how to install LuaRocks. If you're on Windows, may a higher force save you. If you're on neither, I'm sorry.

```
$ luarocks install alfons
```

Of course, the fancy way of installing Alfons would be through Alfons! But Alfons is not a package manager... yet. Stay tuned for Alfons 27.

Make sure that Alfons is installed ok and most importantly, that I didn't fuck up the build. If you get this message, you're good to go.

```
$ alfons
Alfons 4.2
No Taskfile found.
```

## Familiarizing with the interface

When Alfons is run, it looks for `Alfons.lua` first, and then `Alfons.moon`. That's right, Alfons works with both Lua and MoonScript (as long as you have MoonScript installed). I know, I know, MoonScript sucks, that's why I'm writing this tutorial for Lua only. No, I'm not dropping MoonScript support.

If you want to change the file used, you can pass an `-f` or `--file` option to Alfons, and it will use that instead. Unless the file ends in `lua` or `moon`, you will have to tell it the type of language it is using the `--type` option, which accept values `moon` and `lua`.

```
$ alfons --file example.txt --type lua
Alfons 4.2
Using example.txt (lua)
Could not open example.txt: example.txt: No such file or directory
```

## Taskfiles

Now, the moment we were all waiting for. What does this piece of garbage _actually_ do? It just runs defined and named snippets of code. Tasks, if you will. It runs tasks. It takes the names of the tasks you want to run, and runs them. You can make tasks depend on other tasks. You can have tasks for practically anything. We put them in a Taskfile. We will be using `Alfons.lua`. Create that file and then just put this in it:

```lua
function hello()
  print("Hello, world!")
end
```

Now, when you run Alfons, nothing will happen. We need to tell it to run your task. This is quite simple, just do `alfons hello`:

```
$ alfons hello
Alfons 4.2
Using Alfons.lua (lua)
Hello, world!
```

Good! You got your first taskfile running.

## Two tasks?!?!?!

Let's say, hypothetically, that you wanted a task to build and another to clean. Let's say, hypothetically, that Alfons could do that. Just kidding, of course it can. The only thing it can't do is bring back my kids. Just write as many functions as you'd like right beside each other. The order is actually irrelevant.

```lua
function build()
  writefile("build.txt", "build information here")
end

function clean()
  delete("build.txt")
end
```

Here there are two functions that you might not recognize. You can read about `writefile` [here](provide.md#writefile) and `fs` [here](provide.md#delete). It's recommended that you familiarize yourself with the functions that come with Alfons as they will make your life much easier.

Now you can just call them one after each other: `alfons build clean`

## Introspection

All functions accept a single argument called `self`. Admittedly it's a bit empty and underused, but it does an honest job. It contains a field `name` with the name of the task, in case you're procedurally generating them or something. It also contains a field `task` that contains the task itself, if you want to call it recursively. That function takes a table of arguments instead of varargs.

```lua
function myself(self)
  print("I am " .. self.name)
end
```

## Task arguments

Now, for a spin, you can make a task take arguments, like flags and options. To see specifically how they are parsed, look at [this manual page](arguments.md). The arguments can be anything you want, and they will be passed as a table to the functions through the `self` table. Write a task like this:

```lua
function word(self)
  print("My favorite word is " .. self.word)
end
```

Now, if you call it with the `word` option, it will speak back to you!

```
$ alfons word --word oboe
Alfons 4.2
Using Alfons.lua (lua)
My favorite word is oboe
```

## Calling other tasks

Writing many tasks is fun until you start to have to reuse code. You could still make local functions, there's nothing stopping you from doing that, I promise, but chances are that at one point you will want to call another task. In Lua, I _think_ you might be able to call the function directly? It won't have the `name` and `task` fields that's for sure. I also think it won't count towards the total tasks-run number. For your own protection, please use the following method, which is just the `tasks` table:

```lua
function main()
  tasks.another()
end

function another()
  print "It worked!"
end
```

Now just run `alfons main` and try it out!

## Storing data

A way to store data and make it available to all tasks at any given time is using the `store` table. It's just a normal table, but available across every Taskfile that you load.

```lua
function stores()
  store.field = true
end

function gets()
  print(store.field)
end
```

Running `alfons stores gets` will get you `true`!

## Exploring

Those are pretty much the basics to Alfons. From here, it's just exploring! Check out the [Recipes](recipes.md) page for some cool tasks for Alfons.
