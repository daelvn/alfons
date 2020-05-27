return function(pkg, message, prefix, source, branch)
  if message == nil then
    message = "Release"
  end
  if prefix == nil then
    prefix = "v"
  end
  if source == nil then
    source = "origin"
  end
  if branch == nil then
    branch = "master"
  end
  return function(self, ver)
    print(style("%{red}publish-rockspec is deprecated and will be removed in a future update."))
    print(style("%{red}Consider using Rockbuild instead: https://github.com/daelvn/rockbuild"))
    git.tag("-a " .. tostring(prefix) .. tostring(ver) .. " -m '" .. tostring(message) .. " " .. tostring(ver) .. "'")
    git.push(tostring(source) .. " " .. tostring(branch) .. " --tags")
    sh("luarocks upload " .. tostring(pkg) .. "-" .. tostring(ver) .. "-1.rockspec")
    for file in wildcard("*.rock") do
      fs.delete(file)
    end
  end
end
