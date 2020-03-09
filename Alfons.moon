tasks:
  always:        => sh "moonc alfons.moon"
  make:          =>
    sh "luarocks make"
  publish: (ver) =>
    commands = {
      "git tag -a v#{ver} -m 'Release #{ver}'"
      "git push origin master --tags"
      "luarocks upload alfons-#{ver}-1.rockspec"
      "rm *.rock"
    }
    --
    for cmd in *commands
      print cmd
      sh    cmd