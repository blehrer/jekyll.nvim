table.unpack = table.unpack or unpack -- 5.1 compatibility
local M = {}

--[[ function returning a random alphanumeric string of length k --]]
-- https://stackoverflow.com/questions/72523578/is-there-a-way-to-generate-an-alphanumeric-string-in-lua
local random_string = function (k)
  math.randomseed(os.time())
  local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  local n = string.len(alphabet)
  local pw = {}
  for i = 1, k
  do
    pw[i] = string.byte(alphabet, math.random(n))
  end
  return string.char(table.unpack(pw, 1, k))
end

local create_buffer_with_name_and_content = function (path, content, override)
  override = override or false 
  local buf = nil
  if not override and vim.fn.filereadable(path) == 1 then
    vim.cmd.edit(path)
    buf = vim.api.nvim_get_current_buf()
    local last_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(0, {last_line, 0})
  else
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, path)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.schedule(function()
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
      local last_line = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(0, {last_line, 0})
    end)
  end
  return buf
end

M.setup = function ()
  -- pass
end

M.create_post = function ()
  -- Get title from user
  local title = vim.fn.input("Title: ")
  if title == "" then return end
  -- Format date and filename
  local date = os.date("%Y-%m-%d")
  local time = os.date("%H:%M:%S %z")
  local filename = string.format("%s-%s.md",
    date,
    title:lower():gsub(" ", "-"):gsub("[^%w-]", ""))
  local path = vim.fn.expand(vim.uv.cwd() .. "/_posts/" .. filename)
  local content = {
    "---",
    "layout: post",
    string.format("title: '%s'", title),
    string.format("date: %s %s", date, time),
    "categories: ",
    "tags: ",
    "---",
  }
  create_buffer_with_name_and_content(path, content)
end

M.create_note = function()
  local date = os.date("%Y-%m-%d")
  local time = os.date("%H:%M:%S")
  local slug = random_string(5)
  local filename = string.format("%s-%s.md",
    date,
    slug
  )
  local path = vim.fn.expand(vim.uv.cwd() .. "/_notes/" .. filename)
  local content = {"---", string.format("date: %sT%s", date, time), "---"}
  create_buffer_with_name_and_content(path, content)
end
return M
