------
---@class JekyllNvim
---@field setup function(table<string,any>?) called to initialize the plugin
---@field create_post function creates a jekyll post in _posts
---@field create_draft function creates a jekyll post in _drafts
---@field create_note function creates a jekyll note in _notes
---@field promote_draft function converts an existing draft into a published post
------

------
---@alias JekyllUserCommands table<string,function>
------

------
---@class JekyllNvimOptions
---@field augroup_name string is
------

-- vim: ts=2 sts=2 sw=2 et tw=100
