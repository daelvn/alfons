-- alfons.getopt
-- Alfons needs its own getopt because of how it calls tasks.
getopt = (argl) ->
  args  = {
    commands: {}
  }
  flags = {
    stop:    false
    command: false
    wait:    false
  }
  push = (o, v) ->
    if flags.command
      args[flags.command][o] = v
    else
      args[o] = v
  -- loop args
  for arg in *argl
    -- stop parsing
    if arg == "--"
      flags.stop = true
    -- add to args if stopped
    if flags.stop
      table.insert args, arg
      continue
    -- set as value for last if waiting
    if flags.wait
      -- test next arg
      if arg\match "^%-%-"
        -- next argument is another long flag
        -- set waiting flag to current arg, wait for next value
        push (flags.wait\gsub "%-", "_"), true
        flags.wait = arg\match "^%-%-([a-za-z0-9%-_]+)"
      else
        -- next argument is not a long flag
        -- proceed normally
        push (flags.wait\gsub "%-", "_"), arg
        flags.wait = false
      continue
    -- change command
    unless arg\match "^%-%-?"
      args[arg]     = {}
      flags.command = arg
      table.insert args.commands, arg
      continue
    -- add short opt
    if flag = arg\match "^%-(%w)$"
      flags.wait = flag
      continue
    -- add multiple flags
    if flagl = arg\match "^%-(%w+)$"
      for chr in flagl\gmatch "."
        push chr, true
      continue
    -- add option with value
    if arg\match "^%-%-?([a-za-z0-9%-_]+)=(.+)$"
      opt, value = arg\match "^%-%-?([a-zA-Z0-9%-_]+)=(.+)"
      push (opt\gsub "%-", "_"), value
      continue
    -- add option with next value
    if opt = arg\match "^%-%-([a-zA-Z0-9%-_]+)$"
      flags.wait = opt\gsub "%-", "_"
  -- push if waiting
  if flags.wait
    push (flags.wait\gsub "%-", "_"), true
  -- return result
  args

--
{ :getopt }
