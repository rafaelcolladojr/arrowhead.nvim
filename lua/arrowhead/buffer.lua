local M = {}

M.replace_text_with_newlines = function(bufnr, start_row, start_col, end_row, end_col, replacement_text)
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

return M
