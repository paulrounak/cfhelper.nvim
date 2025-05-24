local M = {}

function M.show_results(results)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Calculate max line width
  local max_line_width = 0
  for _, r in ipairs(results) do
    if #r.line > max_line_width then
      max_line_width = #r.line
    end
  end

  local width = math.min(max_line_width + 10, math.floor(vim.o.columns * 0.7))
  local height = math.floor(#results)
  local row = 0
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  local lines = {}
  for _, r in ipairs(results) do
    table.insert(lines, r.line)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns = vim.api.nvim_create_namespace("CFRunHighlight")
  for i, r in ipairs(results) do
    if r.status == "pass" then
      vim.api.nvim_buf_add_highlight(buf, ns, "DiffAdd", i - 1, 0, -1)
    elseif r.status == "fail" or r.status == "diff" then
      vim.api.nvim_buf_add_highlight(buf, ns, "DiffDelete", i - 1, 0, -1)
    end
  end

  -- Keymaps to close the window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return M
