tasks:
  always:        get "ms-compile"
  make:          => sh "luarocks make"
  publish:       (get "publish-rockspec") "alfons"