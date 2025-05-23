local M = {}

local function create_floating_input(prompt_text, on_submit)
  local prompt = prompt_text or ">> "
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 60
  local height = 1

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = 0,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prompt })
  vim.api.nvim_buf_add_highlight(buf, -1, "Question", 0, 0, #prompt)

  -- Place cursor right after prompt
  vim.api.nvim_win_set_cursor(win, { 1, #prompt })

  -- Map <CR> in normal mode to submit input
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_get_current_line()
    local input = line:sub(#prompt + 1):gsub("^%s*(.-)%s*$", "%1") -- trim spaces
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    on_submit(input)
  end, { buffer = buf })

  -- Map <Esc> in normal mode to cancel
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf })
end

function M.prompt_url(on_submit)
  create_floating_input(">> ", function(url)
    if url and url ~= "" then
      on_submit(url)
    else
      print("Cancelled or empty URL.")
    end
  end)
end

return M
