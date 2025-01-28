vim.api.nvim_create_user_command("JekyllPost", function()
  require("jekyll").create_post()
end, {})
