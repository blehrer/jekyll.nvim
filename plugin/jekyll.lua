if vim.g.loaded_jekyll_nvim then
  return
end

local success, result = pcall(require('jekyll').setup)
if not success then
  print(vim.inspect(result))
  return
end
