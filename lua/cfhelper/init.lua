local cf_run = require("cfhelper.CFRun")
local cf_setup = require("cfhelper.CFSetup")

vim.api.nvim_create_user_command("CFRun", function()
  cf_run.run()
end, {})

vim.api.nvim_create_user_command("CFSetup", function()
  require("cfhelper.setup_ui").input_url(function(url)
    local ok, err = pcall(cf_setup.setup, url)
    if ok then
      vim.notify("CFSetup completed for: " .. url, vim.log.levels.INFO, { title = "cfhelper.nvim" })
    else
      vim.notify("CFSetup failed: " .. err, vim.log.levels.ERROR, { title = "cfhelper.nvim" })
    end
  end)
end, {})
