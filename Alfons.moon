tasks:
  always:        => moonc "alfons.moon"
  compileall:    =>
    for file in wildcard "*.moon"
      moonc file
  make:          =>
    sh "luarocks make"
  publish: (ver) =>
    git.tag  "-a v#{ver} -m 'Release #{ver}'"
    git.push "origin master --tags"
    sh "luarocks upload alfons-#{ver}-1.rockspec"
    sh "rm *.rock"