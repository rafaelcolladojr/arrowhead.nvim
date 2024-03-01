local ts = vim.treesitter
local ts_utils = require('nvim-treesitter.ts_utils')
local buffer = require('arrowhead.buffer')

local M = {}

--- Check if the given list contains the given entry
--- @param list table
--- @param value any
--- @return boolean exists
M.contains = function(list, value)
  for _, v in ipairs(list) do
    if (v == value) then
      return true
    end
    return false
  end
end






--- Recursively gets the closest parent node of type function_body or function_expression
---@param node TSNode? The starting none from which to find a function
---@return TSNode? result The parent function node, if it exsits
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






--- Replaces the pattern-matching text within the given node with the given replacement string
--- @param node TSNode The node within which conduct the replacement
--- @param replacement string Text to replace node with
--- @param buffno integer The current buffer number
M.replace_node_text = function(node, replacement, buffno)
  local start_row, end_row, start_col, end_col = node:range()
  buffer.replace_text_with_newlines(buffno, start_row, end_row, start_col, end_col, replacement)
end






---@param node TSNode
---@param buffno integer
---@param is_arg boolean
local function convert_to_fat_arrow(node, buffno, is_arg)

  local return_statement = M.get_child_node_of_type(node, 'return_statement')
  local return_value = M.get_children_node_text(return_statement, buffno)
  local without_return = return_value:sub(7, -1)
  local without__semicolon = without_return:sub(1, -2)
  local value_to_use = is_arg and without__semicolon or without_return

  -- If the function body ends in a character (most likely a comma), exclude semicolon
  local replacement = "=> " .. value_to_use .. "\n"
  M.replace_node_text(node, replacement, buffno)
end






---@param node TSNode The fat arrow function to convert
---@param buffno integer The current buffer's number
local function convert_to_standard(node, buffno)
  -- local pattern = "^%s*=>%s*(.-)%s*;-(,-)%s*$"

  local return_value = M.get_children_node_text(node, buffno)
  local without_arrow = return_value:sub(3, -1)

  if (without_arrow:sub(-1) == ';') then
    without_arrow = without_arrow.sub(1, -2)
  end

  local replacement = "{ return " .. without_arrow .. "; }"

  M.replace_node_text(node, replacement, buffno)
end






--- Converts the provided function node to the opposite notation
---@param node TSNode The function node to convert
---@param ignore_comments boolean Whether to ignore comments when converting to fat arrow
M.convert_function = function(node, ignore_comments)
  local buffno = vim.api.nvim_get_current_buf()
  local first_named_child = node:named_child(0);
  local first_child_text = ts.get_node_text(node:child(0), buffno)

  -- Check if this function is an argument or standalone definition
  -- TODO: Let's not hardcode the path to parent
  local is_arg_function = string.find(node:parent():parent():parent():type(), 'argument') ~= nil

  if (M.is_valid_standard_function(first_named_child, ignore_comments)) then
      convert_to_fat_arrow(first_named_child, buffno, is_arg_function)
  elseif first_child_text == '=>' then
    convert_to_standard(node, buffno)
  else
    print('Arrowhead: Unable to convert function.')
  end
end






--- Checks if the provided standard notation function body is valid for conversion to fat arrow
--- @param node TSNode The node to check if its in a valid format for conversion
--- @param ignore_comments boolean Whether to ignore comments when checking function candidacy
--- @return boolean is_valid
M.is_valid_standard_function = function(node, ignore_comments)
  if node:type() == 'block' then
    local first_child = node:named_child(0)
    if (ignore_comments == false) then
      if first_child:type() == 'return_statement' then
        return true
      else
        return false
      end
    else
      -- Ignore comments
      --- @param child TSNode
      for child, _ in node:iter_children() do
        if (child:named() == false or child:type() == 'comment') then
          -- skip the comment
          goto continue
        elseif (child:type() == 'return_statement') then
          return true
        else
          return false
        end
          ::continue::
      end
    end
  end
  return false
end






--- Get the first child node of specified type
--- @param node TSNode The parent node that the search starts at
--- @param type string The type of node to search for
--- @return TSNode child The child node of the specified type
M.get_child_node_of_type = function(node, type)
  for child, _ in node:iter_children() do
    if (child:type() == type) then
        return child
    end
  end
  return node
end






--- Returns the text value of all children nodes
---@param node TSNode
---@return string
M.get_children_node_text = function(node, buffno)
  local result = ''

  for child, _ in node:iter_children() do
    result = result .. ts.get_node_text(child, buffno)
  end

  return result
end






return M
