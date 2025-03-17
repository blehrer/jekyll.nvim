------
---@class JekyllNvim
---@field user_commands JekyllUserCommands commands that you can use from the : prompt
---@field opts JekyllNvimOptions pluggable values
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
---@field augroup_name string
------
