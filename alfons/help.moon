-- alfons.help
-- Displays help messages
import style from require "ansikit.style"
import map, reduce from require "alfons.provide"
unpack or= table.unpack

Node = (type, content, options) ->
  node = { :type, :content }
  if options then for k, v in pairs options do node[k] = v
  return node
Paragraph = (content) -> Node 'paragraph', content
Columns = (options, content) -> Node 'columns', content, options
Row = (content) -> Node 'row', content
Cell = (content, options) -> Node 'cell', content, options
Cells = (arr) -> map arr, (cell) -> Cell cell[2], cell[1]
Spacer = (length) -> Node 'spacer', '', :length

-- sections: {
--   { type: 'paragraph', content: 'Options:' }
--   { type: 'columns', padding: 2, content: {
--      { type: 'row', content: {
--        { type: 'cell',  }
--      }}
--   } }
-- }
generateHelp = (sections, options={}) ->
  final = ""
  for section in *sections
    final ..= string.rep ' ', options.padding or 0
    switch section.type
      when 'paragraph'
        final ..= (style section.content) .. '\n'
      when 'spacer'
        final ..= string.rep '\n', section.length or 1
      when 'columns'
        -- find maximum width of each column
        columns = section.content
        lengths = {}
        for row_index, row in ipairs columns
          for cell_index, cell in ipairs row.content
            lengths[cell_index] = 0 unless lengths[cell_index]
            if (string.len cell.content) > lengths[cell_index]
              lengths[cell_index] = string.len cell.content
        -- recursively generate section
        for row_index, row in ipairs columns
          final ..= string.rep ' ', section.padding
          for cell_index, cell in ipairs row.content
            cell_length = (string.len cell.content)
            needed_length = lengths[cell_index]
            content = style (cell.color or '') .. (cell.content .. (string.rep ' ', needed_length - cell_length))
            final ..= content .. '   '
          final ..= '\n'
  return final

{
  :Node, :Paragraph, :Spacer, :Columns, :Row, :Cell, :Cells,
  :generateHelp
}
