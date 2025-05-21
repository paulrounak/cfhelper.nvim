-- lua/cfhelper/ui.lua
local M = {}

function M.input_url(callback)
  local input_buf = vim.api.nvim_create_buf(false, true)

  local width = 60
  local height = 1
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(input_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { "" })

  -- Proper scratch buffer settings
  vim.api.nvim_buf_set_option(input_buf, "buftype", "prompt")
  vim.api.nvim_buf_set_option(input_buf, "filetype", "cfhelper_input")
  vim.api.nvim_buf_set_option(input_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(input_buf, "swapfile", false)
  vim.api.nvim_buf_set_option(input_buf, "modifiable", true)
  vim.api.nvim_buf_set_option(input_buf, "buflisted", false)

  vim.fn.prompt_setprompt(input_buf, "> ")
  vim.fn.prompt_setcallback(input_buf, function(input)
    vim.api.nvim_win_close(win, true)
    vim.cmd("redraw!")
    if input and input ~= "" then
      callback(input)
    else
      vim.notify("CFSetup cancelled.", vim.log.levels.WARN, { title = "cfhelper.nvim" })
    end
  end)

  vim.cmd("startinsert")
end

return M
