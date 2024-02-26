local buffer = require('arrowhead.buffer')
local utils = require('arrowhead.utils')


local M = {}

local ts = vim.treesitter


---@param node TSNode
---@param pattern string
---@param replacement string
---@param buffno integer
local function replace_function_text(node, pattern, replacement, buffno)
  local start_row, end_row, start_col, end_col = node:range()
  local node_text = ts.get_node_text(node, 1)

  local new_text = string.gsub(node_text, pattern, replacement)
  buffer.replace_text_with_newlines(buffno, start_row, end_row, start_col, end_col, new_text)
end


---@param node TSNode
---@param buffno integer
local function convert_to_fat_arrow(node, buffno, trailing_char)

  local pattern = "^%s*{%s*return%s*(.-)%s*(;-)%s*}"
  -- If the function body ends in a character (most likely a comma), exclude semicolon
  local replacement = "=> %1" .. (trailing_char == "" and "%2" or "") .. "\n"
  -- print(vim.inspect(trailing_char))

  replace_function_text(node, pattern, replacement, buffno)
end

---@param node TSNode
---@param buffno integer
local function convert_to_standard(node, buffno, trailing_char)
  local pattern = "^%s*=>%s*(.-)%s*;-(,-)%s*$"
  local replacement = "{ return %1; " .. (trailing_char == "" and "" or "\n}") .. "%2"

  replace_function_text(node, pattern, replacement, buffno)
end




---@param node TSNode
local function convert_function(node)
  local buffno = vim.api.nvim_get_current_buf()
  local first_named_child = node:named_child(0);
  local first_child_text = ts.get_node_text(node:child(0), buffno)
  local trailing_char = utils.get_trailing_char(1, node)

  if first_named_child:type() == 'block' then
    local second_named_child = first_named_child:named_child(0)
    -- TODO: Ignore comments
    if second_named_child:type() == 'return_statement' then
      convert_to_fat_arrow(first_named_child, buffno, trailing_char)
    else
      error('Unable to convert function to fat arrow')
      return
    end
  elseif first_child_text == '=>' then
    convert_to_standard(node, buffno)
  else
    -- print(ts.get_node_text(node, buffno))
  end
end




-- PUBLIC NOTATION SWAPPING COMMAND
M.swap_notation = function()
  local curr_node = ts.get_node()
  if (curr_node == nil) then
    error("No treesitter parser found.")
  end

  -- print(ts.get_node_text(curr_node, 1))

  local closest_function = utils.get_closest_function(curr_node)
  if (closest_function == nil) then
    return
  end

  -- get_text_after_node(1, closest_function)
  convert_function(closest_function)
end

return M
