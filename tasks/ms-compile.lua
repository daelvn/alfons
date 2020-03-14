return function(self)
  for file in wildcard("**.moon") do
    local _continue_0 = false
    repeat
      if file:match("Alfons%.moon") then
        _continue_0 = true
        break
      end
      moonc(file)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
