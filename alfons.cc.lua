-- Wrapper for alfons+bsrocks
local execstring = "bsrocks exec /rocks/bin/alfons.lua"
for i, argument in ipairs (arg) do execstring = execstring .. " " .. argument end
shell.run (execstring)
