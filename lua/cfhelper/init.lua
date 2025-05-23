local cf_run = require("cfhelper.CFRun")
local cf_setup = require("cfhelper.CFSetup")

vim.api.nvim_create_user_command("CFRun", function()
  cf_run.run()
end, {})

vim.api.nvim_create_user_command("CFSetup", function()
  cf_setup.setup()
end, {})
