local M = {}

local ts = vim.treesitter
local ts_utils = require("nvim-treesitter.ts_utils")

local function replace_text_with_newlines(bufnr, start_row, start_col, end_row, end_col, replacement_text)
  -- Split the replacement text into lines
  local replacement_lines = {}
  for line in replacement_text:gmatch("([^\n]*)\n?") do
    if line ~= "" then
      table.insert(replacement_lines, line)
    end
  end

  -- Get the text before and after the replacement range in the first and last line
  local first_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
  local last_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1]
  local prefix = first_line:sub(1, start_col)
  local suffix = last_line:sub(end_col + 1)

  -- Modify the first and last replacement lines to include the prefix and suffix
  replacement_lines[1] = prefix .. replacement_lines[1]
  replacement_lines[#replacement_lines] = replacement_lines[#replacement_lines] .. suffix

  -- Replace the lines in the buffer
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row + 1, false, replacement_lines)
end

local function get_trailing_char(bufnr, node)
  -- Get the end position of the node
  local end_row, end_col = node:end_()

  -- Set the range to start after the node and end at the end of the line
  -- You can adjust the range as needed
  local start_row = end_row
  local start_col = end_col
  local end_row = start_row
  local end_col = -1  -- -1 indicates the end of the line

  -- Get the text in the range
  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
  -- print(vim.inspect(lines))

  -- Join the lines to get the full text
  local text_after_node = table.concat(lines, "\n")

  return text_after_node
end



-- Recursively gets the closest parent node of type function_body or function_expression
---@param node TSNode?
---@return TSNode? result
local function get_closest_function(node)
  if not node then
    return nil
  end

  if node:type() == 'function_signature' then
    node = node:next_sibling()
  end

  --- Is current node a funciton
  if node:type() == 'function_body' or node:type() == 'function_expression_body' then
    return node
  end

  local parent_node = node:parent()
  local root_node = ts_utils.get_root_for_node(node)

  if (not parent_node or parent_node == root_node) then
    return nil
  end

  return get_closest_function(parent_node)
end


---@param node TSNode
---@param pattern string
---@param replacement string
---@param buffno integer
local function replace_function_text(node, pattern, replacement, buffno)
  local start_row, end_row, start_col, end_col = node:range()
  local node_text = ts.get_node_text(node, 1)

  local new_text = string.gsub(node_text, pattern, replacement)
  replace_text_with_newlines(buffno, start_row, end_row, start_col, end_col, new_text)
end


---@param node TSNode
---@param buffno integer
local function convert_to_fat_arrow(node, buffno, trailing_char)

  local pattern = "^%s*{%s*return%s*(.-)%s*(;-)%s*}"
  -- If the function body ends in a character (most likely a comma), exclude semicolon
  local replacement = "=> %1" .. (trailing_char == "" and "%2" or "")
  -- print(vim.inspect(trailing_char))

  replace_function_text(node, pattern, replacement, buffno)
end

---@param node TSNode
---@param buffno integer
local function convert_to_standard(node, buffno)
  local pattern = "^%s*=>%s*(.-)%s*;-(,-)%s*$"
  local replacement = "{ return %1; }%2"

  replace_function_text(node, pattern, replacement, buffno)
end




---@param node TSNode
local function convert_function(node)
  local buffno = vim.api.nvim_get_current_buf()
  local first_named_child = node:named_child(0);
  local first_child_text = ts.get_node_text(node:child(0), buffno)
  local trailing_char = get_trailing_char(1, node)

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




-- PUBLIC BOILERPLATE GENERATION COMMAND
M.swap_notation = function()
  local curr_node = ts.get_node()
  if (curr_node == nil) then
    error("No treesitter parser found.")
  end

  -- print(ts.get_node_text(curr_node, 1))

  local closest_function = get_closest_function(curr_node)
  if (closest_function == nil) then
    return
  end

  -- get_text_after_node(1, closest_function)
  convert_function(closest_function)
end

return M
