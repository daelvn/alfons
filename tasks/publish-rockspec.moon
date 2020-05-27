(pkg, message="Release", prefix="v", source="origin", branch="master") -> (ver) =>
  print style "%{red}publish-rockspec is deprecated and will be removed in a future update."
  print style "%{red}Consider using Rockbuild instead: https://github.com/daelvn/rockbuild"
  git.tag  "-a #{prefix}#{ver} -m '#{message} #{ver}'"
  git.push "#{source} #{branch} --tags"
  sh "luarocks upload #{pkg}-#{ver}-1.rockspec"
  for file in wildcard "*.rock" do fs.delete file