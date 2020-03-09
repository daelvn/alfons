tasks:
  always:        => sh "moonc alfons.moon"
  publish: (ver) =>
    sh "git tag -a #{ver} -m 'Release #{ver}'"
    sh "git push origin master --tags"
    sh "luarocks upload alfons-#{ver}-1.rockspec"
    sh "rm *.rock"