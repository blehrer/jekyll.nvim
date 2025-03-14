if vim.g.loaded_jekyll_nvim then
  return
end

local success, result = pcall(require('jekyll').setup)
if not success then
  print(vim.inspect(result))
  return
end

local path = require 'plenary.path'
local util = require 'lazy.util'

local function is_jekyll_window()
  local cwd = vim.fn.getcwd()
  local gemfile = path:new(cwd .. '/Gemfile')
  local gemfile_lines = path.exists(gemfile) and path.readlines(gemfile) or {}
  local all_matches = util.filter(function(line)
    return string.match(line, '.*jekyll.*')
  end, gemfile_lines)
  return #all_matches > 0
end

vim.api.nvim_create_augroup('Jekyll', { clear = true })
vim.api.nvim_create_autocmd('DirChanged', {
  group = 'Jekyll',
  callback = function(_)
    local jekyll = require 'jekyll'
    if jekyll then
      if is_jekyll_window() and not vim.g.loaded_jekyll_nvim then
        jekyll.setup()
      else
        jekyll.deactivate()
      end
    end
  end,
})
