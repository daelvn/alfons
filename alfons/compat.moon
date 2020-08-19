-- alfons.compat
-- Compatibility for all Lua versions
setfenv or= (fn, env) ->
  i = 1
  while true
    name = debug.getupvalue fn, i
    if name == "_ENV"
      debug.upvaluejoin fn, i, (-> env), 1
    elseif not name then break
    i += 1
  return fn

{ :setfenv }