local utils = require('arrowhead.utils')
local buffer = require('arrowhead.buffer')
local ts = vim.treesitter


local M = {}



--- Swap the notation of the function/method under the cursor
---@param ignore_comments boolean? Whether to ignore comments when converting to fat arrow. default: false
---@diagnostic disable-next-line: unused-local
M.swap_notation = function(ignore_comments)
  --- Don't ignore comments by default
  ignore_comments = ignore_comments or false

  if (buffer.is_language_supported()) then
    vim.notify('Unsupported language.')
    return
  end

  local curr_node = ts.get_node()
  if (curr_node == nil) then
    print("Arrowhead: No treesitter parser found.")
  end

  local closest_function = utils.get_closest_function(curr_node)
  if (closest_function == nil) then
    return
  end

  utils.convert_function(closest_function, ignore_comments)
end



return M
