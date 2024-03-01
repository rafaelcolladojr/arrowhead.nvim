local ts = vim.treesitter
local ts_query = ts.query;

local M = {}

--- Returns the return_statement of the given function node
--- @param node TSNode
--- @return TSNode? return_statement
M.get_return_statement = function(node)
  local query_string = [[
    (return_statement) @return_stmt
  ]]

  local bufnr = vim.api.nvim_get_current_buf()
  local parser = ts.get_parser(bufnr)
  local query = ts_query.parse(parser:lang(), query_string)

  local start_row, _, end_row, _ = node:range()

  for _, match in query:iter_matches(node, bufnr, start_row, end_row) do
    return match[1]
  end
  return nil
end

return M
