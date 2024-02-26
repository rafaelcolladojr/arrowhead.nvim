local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

-- Recursively gets the closest parent node of type function_body or function_expression
---@param node TSNode?
---@return TSNode? result
M.get_closest_function = function(node)
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

  return M.get_closest_function(parent_node)
end





-- Returns the trailing character after the function body
--- @param bufnr integer
--- @param node TSNode
--- @return string trailing_char The character directly following the provided function's body
M.get_trailing_char = function(bufnr, node)
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

return M
