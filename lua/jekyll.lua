local M = {}

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
    -- Create full path (adjust this to your Jekyll posts directory)
    local path = vim.fn.expand(vim.fn.getcwd() .. "/_posts/" .. filename)
    -- Create the file content
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
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
        -- Open the new file in the current buffer
        vim.cmd("edit " .. path)
        -- Move cursor to the categories line
        vim.cmd("normal! 5G$")
    else
        vim.notify("Failed to create post", vim.log.levels.ERROR)
    end
end

M.create_note = function()
  -- TODO 
end
return M
