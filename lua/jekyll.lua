table.unpack = table.unpack or unpack -- 5.1 compatibility
local M = {}

--[[ function returning a random alphanumeric string of length k --]]
-- https://stackoverflow.com/questions/72523578/is-there-a-way-to-generate-an-alphanumeric-string-in-lua
M._random_string = function (k)
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

M.setup = function ()
  -- pass
end

M._create_file_with_content = function (path, content)
  -- Write the file
  local file = io.open(path, "w")
  if file then
    file:write(content)
    file:close()
  end
  return file
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
  local path = vim.fn.expand(vim.fn.getcwd() .. "/_posts/" .. filename)
  local content = string.format([[
---
layout: post
title: "%s"
date: %s %s
categories: 
tags: 
---

]], title, date, time)

  -- Write the file
  local file = M._create_file_with_content(path, content)
  if file then
    -- Open the new file in the current buffer
    vim.cmd("edit " .. path)
    -- Move cursor to the categories line
    vim.cmd("normal! GG$")
  else
    vim.notify("Failed to create post", vim.log.levels.ERROR)
  end
end

M.create_note = function()
  local date = os.date("%Y-%m-%d")
  local time = os.date("%H:%M:%S %z")
  local hash = M._random_string(5)
  local filename = string.format("%s-%s.md",
    date,
    hash
  )
  local path = vim.fn.expand(vim.fn.getcwd() .. "/_notes/" .. filename)
  local content = string.format([[
--- 
date: %sT%s
---
]], date, time)
  -- Write the file
  local file = M._create_file_with_content(path, content)
  if file then
    -- Open the new file in the current buffer
    vim.cmd("edit " .. path)
    -- Move cursor to the categories line
    vim.cmd("normal! GG$")
  else
    vim.notify("Failed to create post", vim.log.levels.ERROR)
  end

end
return M
