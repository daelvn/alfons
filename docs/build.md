# build

`build` takes an iterator and a function. It gets all the files from the iterator,
checks their modification time, compares it to a cache, and passes the filename to the function if the file was modified.

## Behavior

The cache is stored in an `.alfons` file. If it does not exist, then all filenames will be passed to the function, and then stored in cache. If it does exist, then the comparison happens.

## Examples

### Compiling MoonScript

```lua
compile = function(self)
  build((wildcard "**.moon"), function(file)
    sh "moonc " .. file
  end)
end
```

```moon
tasks:
  compile:
    build (wildcard "**.moon"), -> sh "moonc #{file}"
```