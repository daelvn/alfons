-- alfons.parser
-- Parses comments and other information in a taskfile
import lines, sanitize, map, filter, split, slice, keys from require "alfons.provide"
import style from require "ansikit.style"

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
-- == Describing task option ==
-- --- @option task_name [argument] <input?> Description
-- --- @option release [version v] <version:string> Version of the release.
-- --- @option status [info i] Shows status information.
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
      return "task", name, { :description, options: {} } 
    when "flag"
      parts = split rest, '%s+'
      name, flag = parts[1], parts[2]
      return (name == '*' and "flag" or "task-flag"), name, flag
    when "option"
      parts = split rest, '%s+'
      task = parts[1]
      option_names, option_values, description = {}, {}, ""
      in_option_names, in_option_values, maybe_description, in_description = false, false, false, false
      for part in *parts[2,]
        stripped_part = part\match "([^%[%]%<%>]+)"
        -- realize where we are IN
        if not in_option_names and part\match "^%["
          in_option_names = true
        if not in_option_values and part\match "^%<"
          in_option_values = true
        if maybe_description and not part\match "^%<"
          maybe_description = false
          in_description = true
        -- add part depending in area
        if in_option_names
          table.insert option_names, stripped_part
        if in_option_values
          -- set as optional if ends with ?
          part_object = value: stripped_part
          if stripped_part\match '%?$'
            part_object =
              value: (stripped_part\match "([^%?]+)%?$"),
              optional: true
          table.insert option_values, part_object
        if in_description
          description ..= part .. " "
        -- realize where we are OUT
        if in_option_names and part\match "%]$"
          in_option_names = false
          maybe_description = true
        if in_option_values and part\match "%>$"
          in_option_values = false
          in_description = true
      return "option", task, { :option_names, :option_values, :description }

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
      when "option"
        unless state.tasks[key]
          state.tasks[key] = {}
        state.tasks[key].options[value.option_names[1]] = {
          names: value.option_names,
          values: value.option_values,
          description: value.description,
        }
  return state

{ :parseComments }
