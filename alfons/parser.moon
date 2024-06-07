-- alfons.parser
-- Parses comments and other information in a taskfile
import lines, sanitize, map, filter, split, slice, keys from require "alfons.provide"
import style from require "ansikit.style"
inspect = require "inspect"

printerr = (t) -> io.stderr\write t .. "\n"
errors = (code, msg) ->
  printerr style "%{red}#{msg}"
  os.exit code
--# Comments #--
-- Comments are untied from the code itself, to avoid having to
-- parse every language with comment ASTs, with MoonScript does
-- not even support (Yuescript does, though?).
-- As such, comments must include directives in them to know
-- what tasks they are referring to. Here is the documentation
-- for that.
--
-- == Describing a task ==
-- --- @task task_name Description
-- --- @task compile Compiles the code.
-- == Describing task arguments ==
-- --- @argument task_name [argument] <input?> Description
-- --- @argument release [version v] <version:string> Version of the release.
-- --- @argument status [info i] <> Shows status information.
-- == Enabling flags for a task ==
-- --- @flag task_name flags
-- --- @flag * hide
-- = Builtin flags =
--   hide         - Hides the task from autocompletion and help

parseDirective = (directive) ->
  return false unless directive\match "^@"
  operation = directive\match "^@([a-z]+)"
  rest = directive\match "^@[a-z]+%s+(.+)"
  switch operation
    when "task"
      parts = split rest, '%s+'
      name = parts[1]
      description = table.concat (slice parts, 2), ' '
      return "task", name, { :description, arguments: {} } 
    when "flag"
      parts = split rest, '%s+'
      name, flag = parts[1], parts[2]
      return (name == '*' and "flag" or "task-flag"), name, flag
    when "argument"
      parts = split rest, '%s+'
      task = parts[1]
      argument_names, argument_values, description = {}, {}, ""
      in_argument_names, in_argument_values, in_description = false, false, false
      for part in *parts[2,]
        stripped_part = part\match "([^%[%]%<%>]+)"
        -- realize where we are IN
        if not in_argument_names and part\match "^%["
          in_argument_names = true
        if not in_argument_values and part\match "^%<"
          in_argument_values = true
        -- add part depending in area
        if in_argument_names
          table.insert argument_names, stripped_part
        if in_argument_values
          -- set as optional if ends with ?
          part_object = value: stripped_part
          if stripped_part\match '%?$'
            part_object =
              value: (stripped_part\match "([^%?]+)%?$"),
              optional: true
          table.insert argument_values, part_object
        if in_description
          description ..= part .. " "
        -- realize where we are OUT
        if in_argument_names and part\match "%]$"
          in_argument_names = false
        if in_argument_values and part\match "%>$"
          in_argument_values = false
          in_description = true
      return "argument", task, { :argument_names, :argument_values, :description }

-- Parses all comments starting with a certain marker '---'
parseComments = (content, marker = '---') ->
  comment_lines = filter (lines content), (line) ->
    line\match "^%s-#{sanitize marker}%s+"
  directives = map comment_lines, (line) ->
    line\match "#{sanitize marker}%s+(.+)"
  state =
    tasks: {}
    flags: {}
  map directives, (directive) ->
    operation, key, value = parseDirective directive
    switch operation
      when "task"
        state.tasks[key] = value
      when "flag"
        table.insert state.flags, value
      when "task-flag"
        unless state.tasks[key]
          state.tasks[key] = {}
        if "table" == type state.tasks[key].flags
          table.insert state.tasks[key].flags, value
        else
          state.tasks[key].flags = {value}
      when "argument"
        -- print "argument", inspect {:key, :value, :state}
        unless state.tasks[key]
          state.tasks[key] = {}
        state.tasks[key].arguments[value.argument_names[1]] = {
          names: value.argument_names,
          values: value.argument_values,
          description: value.description,
        }
  return state

-- parseComments [[
-- --- @task pack Use amalg to pack Alfons
-- --- @argument pack [output o] <file:string> Output file
-- ]]

{ :parseComments }
