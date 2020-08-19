# Alfons 4
<a href="https://discord.gg/Y75ZXrD"><img src="https://img.shields.io/static/v1?label=discord&message=chat&color=brightgreen&style=flat-square"></a> 
![GitHub stars](https://img.shields.io/github/stars/daelvn/alfons?style=flat-square)
![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/daelvn/alfons?include_prereleases&label=release&style=flat-square)
![LuaRocks](https://img.shields.io/luarocks/v/daelvn/alfons?style=flat-square)

<img align="left" width="128" height="128" src=".github/alfons-logo.svg">
<!-- <img src=".github/alfons-banner.png"> -->

> Alfons 4 is a rewrite of the original Alfons, written to be much more modular and usable. For the old Alfons 3, see the [`three`](https://github.com/daelvn/alfons/tree/three) GitHub branch.

Alfons is a task runner to help you manage your project. It's inspired by the worst use cases of Make (this means using `make` instead of shell scripts), it will read an Alfonsfile, extract the exported functions and run the tasks in order. I would tell you that there is no real reason to use this thing, but it's becoming surprisingly useful, so actually try it out.

## Usage

Run `alfons` in a directory with an `Alfons.lua` or `Alfons.moon` file. Using MoonScript (obviously) requires installing MoonScript via LuaRocks.

To see the documentation,, check out the `docs/` folder of this repo.

## Installing

Since this is not upstream yet, you can't install through the LuaRocks server. However, you can install Alfons using itself.

```sh
$ git clone --branch rewrite daelvn/alfons
$ moon bin/alfons.moon compile pack  # you will need moonscript and amalg.lua for this
$ moon bin/alfons.moon make -v 4.0   # you will need rockbuild for this
# Alternatively, if you want to install unbundled
$ git clone --branch rewrite daelvn/alfons
$ moon bin/alfons.moon compile
$ rockbuild -f rock-dev.yml -m --delete 4.0
```

### Extra features

The preincluded task `fetch` depends on [lua-http](https://github.com/daurnimator/lua-http) to be used. The `watch` function depends on [linotify](https://github.com/hoelzro/linotify) and will not work on platforms other than Linux.

```sh
$ luarocks install http     # lua-http
$ luarocks install inotify  # linotify
```

## License

Throwing it to the public domain. Check out the [license](https://github.com/daelvn/alfons/blob/rewrite/LICENSE.md).

## Goodbye?

goodbye.