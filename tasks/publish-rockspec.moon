(pkg, message="Release", prefix="v", source="origin", branch="master") -> (ver) =>
  git.tag  "-a #{prefix}#{ver} -m '#{message} #{ver}'"
  git.push "#{source} #{branch} --tags"
  sh "luarocks upload #{pkg}-#{ver}-1.rockspec"
  for file in wildcard "*.rock" do fs.delete file