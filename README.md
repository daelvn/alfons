# Alfons 4

> Alfons 4 is a rewrite of the original Alfons, written to be much more modular and usable. For the old Alfons 3, see the [`three`](https://github.com/daelvn/alfons/tree/three) GitHub branch.

Alfons is a task runner to help you manage your project. It's inspired by the worst use cases of Make (this means using `make` instead of shell scripts), it will read an Alfonsfile, extract the exported functions and run the tasks.

## Usage

Run `alfons` in a directory with an `Alfons.lua` or `Alfons.moon` file. Using MoonScript (obviously) requires installing MoonScript via LuaRocks.

### Arguments

Arguments can be a bit weird due to the nature of tasks. This is different from how it used to be in Alfons 3. It probably helps to see it visually in this example:

```py
$ alfons -i command -abc -f=yes.txt next --file another.txt --flag
# The resulting argument structure would be
{
  i = true,
  command = {
    a = true,
    b = true,
    c = true,
    f = "yes.txt"
  },
  next = {
    file = "another.txt",
    flag = true
  } 
}
```