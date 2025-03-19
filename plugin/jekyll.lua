if vim.g.loaded_jekyll_nvim then
  return
end

local success, result = pcall(require('jekyll').setup)
if not success then
  print(vim.inspect(result))
  return
end

-- vim: ts=2 sts=2 sw=2 et tw=100
