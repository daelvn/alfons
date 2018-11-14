local ansicolors, inspect
if not pcall(function()
  ansicolors = require("ansicolors")
end) then
  ansicolors = false
end
if not pcall(function()
  inspect = require("inspect")
end) then
  inspect = false
end
local slow_write
slow_write = function(text, rate)
  text = text and (tostring(text)) or ""
  rate = rate and 1 / (tonumber(rate)) or 1 / 20
  for n = 1, text:len() do
    os.sleep(rate)
    io.write(text:sub(n, n))
  end
end
local slow_print
slow_print = function(text, rate)
  slow_write(text, rate)
  return print()
end
local starts_with
starts_with = function(text, start)
  return (text:sub(1, start:len())) == start
end
local ends_with
ends_with = function(text, ends)
  return (text:sub(-(ends:len()))) == ends
end
local first_upper
first_upper = function(text)
  if text then
    return text:gsub("^%l", string.upper)
  end
end
local first_word_upper
first_word_upper = function(text)
  if text then
    return text:gsub("%a", string.upper, 1)
  end
end
local first_lower
first_lower = function(text)
  if text then
    return text:gsub("^%u", string.lower)
  end
end
local first_word_lower
first_word_lower = function(text)
  if text then
    return text:gsub("%a", string.lower, 1)
  end
end
local title_case
title_case = function(text)
  return text:gsub("(%a)([%w_']*)", function(first, rest)
    if text then
      return first:upper() .. rest:lower()
    end
  end)
end
local all_lower
all_lower = function(text)
  if text then
    return text:gsub("%f[%a]%u+%f[%A]", string.lower)
  end
end
local all_upper
all_upper = function(text)
  if text then
    return text:gsub("%f[%a]%l+%f[%A]", string.upper)
  end
end
local url_encode
url_encode = function(text)
  if text then
    text = text:gsub("\n", "\r\n")
    text = text:gsub("([^%w %-%_%.%~])", function(c)
      return ("%%%02X"):format(string.byte(c))
    end)
    text = text:gsub(" ", "+")
  end
end
local url_decode
url_decode = function(text)
  if text then
    text = text:gsub("+", " ")
    text = text:gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
    text = text:gsub("\r\n", "\n")
  end
end
local trimr
trimr = function(text)
  if text then
    return text:match("(.-)%s*$")
  end
end
local triml
triml = function(text)
  if text then
    return text:match("^%s*(.*)")
  end
end
local trim
trim = function(text)
  if text then
    return trimr(triml(text))
  end
end
local split
split = function(text, sep, max, plain)
  if sep == nil then
    sep = " "
  end
  if sep == "" then
    sep = " "
  end
  local parts = { }
  if text:len() > 0 then
    max = max or -1
    local nf, ns = 1, 1
    local nl
    nf, nl = text:find(sep, ns, plain)
    while nf and (max ~= 0) do
      parts[nf] = text:sub(ns, nf - 1)
      nf = nf + 1
      ns = nl + 1
      nf, nl = text:find(sep, ns, plain)
      local nm = nm - 1
    end
    parts[nf] = text:sub(ns)
  end
  return parts
end
local _arrow
_arrow = function(text, full)
  if full == nil then
    full = true
  end
  return "=> " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local _dart
_dart = function(text, full)
  if full == nil then
    full = true
  end
  return "-> " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local _pin
_pin = function(text, full)
  if full == nil then
    full = true
  end
  return "-- " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local _bullet
_bullet = function(text, full)
  if full == nil then
    full = true
  end
  return " * " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local _quote
_quote = function(text, full)
  if full == nil then
    full = true
  end
  return " > " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local _title
_title = function(text, full)
  if full == nil then
    full = true
  end
  return "== " .. tostring((function()
    if not full then
      return "%{reset}"
    else
      return ""
    end
  end)()) .. tostring(text)
end
local arrow
arrow = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "blue"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_arrow(text, full)))
  else
    return _arrow(text)
  end
end
local dart
dart = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "cyan"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_dart(text, full)))
  else
    return _dart(text)
  end
end
local pin
pin = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "green"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_pin(text, full)))
  else
    return _pin(text)
  end
end
local bullet
bullet = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "green"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_bullet(text, full)))
  else
    return _bullet(text)
  end
end
local quote
quote = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "magenta"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_quote(text, full)))
  else
    return _quote(text)
  end
end
local title
title = function(text, full, color)
  if full == nil then
    full = true
  end
  if color == nil then
    color = "magenta"
  end
  if ansicolors then
    return ansicolors("%{" .. tostring(color) .. "}" .. tostring(_title(text, full)))
  else
    return _title(text)
  end
end
local printf
printf = function(text, ...)
  return print(string.format(text, ...))
end
local set_foreground, set_background, printc, printcf
if ansicolors then
  set_foreground = function(color)
    return ansicolors.noReset("%{" .. tostring(color) .. "}")
  end
  set_background = function(color)
    return ansicolors.noReset("%{" .. tostring(color) .. "bg}")
  end
  printc = function(text)
    return print(ansicolors(text))
  end
  printcf = function(text, ...)
    return print(ansicolors(string.format(text, ...)))
  end
end
local printi
if inspect then
  printi = function(any)
    return print(inspect(any))
  end
end
return {
  slow_write = slow_write,
  slow_print = slow_print,
  starts_with = starts_with,
  ends_with = ends_with,
  first_upper = first_upper,
  first_word_upper = first_word_upper,
  first_lower = first_lower,
  first_word_lower = first_word_lower,
  all_upper = all_upper,
  all_lower = all_lower,
  title_case = title_case,
  url_encode = url_encode,
  url_decode = url_decode,
  trimr = trimr,
  triml = triml,
  trim = trim,
  split = split,
  arrow = arrow,
  dart = dart,
  pin = pin,
  bullet = bullet,
  quote = quote,
  title = title,
  printf = printf,
  set_foreground = set_foreground,
  set_background = set_background,
  printc = printc,
  printcf = printcf,
  printi = printi
}
