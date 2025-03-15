--[[ type declarations ]]

---@class JekyllNvim
---@field user_commands? table<string,function> commands that are registered that you can use from the : prompt
---@field opts? JekyllNvimOptions pluggable values
---@field setup? function(table<string,string>?) called to initialize the plugin
---@field disable? function unregisters user commands, used by package manager to signify the plugin should be uninstalled
---@field deactivate? function unregisters user commands
---@field create_post? function
---@field create_draft? function
---@field create_note? function
---@field promote_draft? function

---@class JekyllNvimOptions
---@field augroup_name string

local jekyll_plugin = 'jekyll'
---@type JekyllNvim
local M = {}

---@type JekyllNvimOptions
M.opts = {
  augroup_name = 'Jekyll',
}

---@type table<string,function>
M.user_commands = {
  JekyllDraft = function()
    require(jekyll_plugin).create_draft()
  end,
  JekyllPost = function()
    require(jekyll_plugin).create_post()
  end,
  JekyllPromote = function()
    require(jekyll_plugin).promote_draft()
  end,
  JekyllNote = function()
    require(jekyll_plugin).create_note()
  end,
}

--[[ utilities ]]

table.unpack = table.unpack or unpack -- 5.1 compatibility
local Path = require('plenary.path')
local telescope = require('telescope.builtin')

local random_string = function(k)
  --[[ function returning a random alphanumeric string of length k --]]
  -- https://stackoverflow.com/questions/72523578/is-there-a-way-to-generate-an-alphanumeric-string-in-lua
  math.randomseed(os.time())
  local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  local n = string.len(alphabet)
  local pw = {}
  for i = 1, k do
    pw[i] = string.byte(alphabet, math.random(n))
  end
  return string.char(table.unpack(pw, 1, k))
end

local create_buffer_with_name_and_content = function(path, content, override)
  override = override or false
  local buf = nil
  if not override and vim.fn.filereadable(path) == 1 then
    vim.cmd.edit(path)
    buf = vim.api.nvim_get_current_buf()
    local last_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(0, { last_line, 0 })
  else
    buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_buf_set_name(buf, path)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    vim.schedule(function()
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
      local last_line = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(0, { last_line, 0 })
    end)
  end
  return buf
end

local create_post_or_draft = function(title, folder, date_and_time)
  if title == '' then
    return
  end
  local title_slug = title:lower():gsub(' ', '-'):gsub('[^%w-]', '')
  local filename = string.format('%s.md', title_slug)
  local time = os.date('%H:%M:%S %z')
  local date = os.date('%Y-%m-%d')
  if date_and_time then
    filename = string.format('%s-%s.md', date, title_slug)
  end
  local path = vim.fn.expand(vim.uv.cwd() .. '/' .. folder .. '/' .. filename)
  local content = {
    '---',
    'layout: post',
    string.format("title: '%s'", title),
    'categories: ',
    'tags: ',
    '---',
  }
  if date_and_time then
    local date_front_matter = string.format('date: %sT%s', date, time)
    table.insert(content, 3, date_front_matter)
  end
  create_buffer_with_name_and_content(path, content)
end

local create_user_commands = function()
  for name, command in pairs(M.user_commands) do
    vim.api.nvim_create_user_command(name, command, {})
  end
  vim.g.loaded_jekyll_nvim = true
end

local del_user_commands = function()
  local user_commands = vim.api.nvim_get_commands({ builtin = false })
  for key, _ in pairs(M.user_commands) do
    if vim.fn.has_key(user_commands, key) then
      vim.api.nvim_del_user_command(key)
    end
  end
  vim.g.loaded_jekyll_nvim = false
end

---@return boolean
local is_jekyll_window = function()
  local gemfile = Path:new(vim.uv.cwd(), 'Gemfile')
  local gemfile_lines = Path.exists(gemfile) and Path.readlines(gemfile) or {}
  return vim.tbl_contains(gemfile_lines, function(line)
    return string.match(line, '.*jekyll.*')
  end)
end

---@param opts JekyllNvimOptions
---@return boolean
local augroup_exists = function(opts)
  return pcall(vim.cmd('au ' .. opts.augroup_name))
end

---@param opts JekyllNvimOptions
---@return boolean
local aucmds_exist = function(opts)
  local success, rv = augroup_exists(opts)
  if success then
    return #rv > 0
  end
  return false
end

---@param opts JekyllNvimOptions
local setup_augroup = function(opts)
  if augroup_exists(opts) then
    print('augroup ' .. opts.augroup_name .. ' already exists')
    return
  else
    print('Creating augroup' .. opts.augroup_name)
    vim.api.nvim_create_augroup(opts.augroup_name, {})
  end
end

---@param opts JekyllNvimOptions
local setup_autocmds = function(opts)
  setup_augroup(opts)
  if not aucmds_exist(opts) then
    vim.api.nvim_create_autocmd('DirEntered', {
      group = opts.augroup_name,
      callback = function(_)
        if is_jekyll_window() then
          create_user_commands()
        else
          del_user_commands()
        end
      end,
    })
  end
end

---@param opts JekyllNvimOptions?
M.setup = function(opts)
  local merged_options = vim.tbl_extend('force', M.opts, opts)
  create_user_commands()()
  setup_autocmds(merged_options)
end

M.create_post = function()
  local title = vim.fn.input('Title: ')
  create_post_or_draft(title, '_posts', true)
end

M.create_draft = function()
  local title = vim.fn.input('Title: ')
  create_post_or_draft(title, '_drafts', false)
end

M.create_note = function()
  local date = os.date('%Y-%m-%d')
  local time = os.date('%H:%M:%S')
  local slug = random_string(5)
  local filename = string.format('%s-%s.md', date, slug)
  local path = vim.fn.expand(vim.uv.cwd() .. '/_notes/' .. filename)
  local content = { '---', string.format('date: %sT%s', date, time), '---' }
  create_buffer_with_name_and_content(path, content)
end

M.promote_draft = function()
  local drafts_dir = Path:new(vim.uv.cwd(), '_drafts')
  local posts_dir = Path:new(vim.uv.cwd(), '_posts')
  telescope.find_files({
    prompt_title = 'Select Draft to Promote',
    cwd = tostring(drafts_dir),
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        local date_prefix = os.date('%Y-%m-%d')
        local draft_path = Path:new(drafts_dir .. '/' .. selection.value)
        local new_filename = date_prefix .. '-' .. selection.value
        local new_path = Path:new(posts_dir, new_filename)
        local content = draft_path:read()
        content = content:gsub('date:.-\n', '')
        local date_line = 'date: ' .. os.date('%Y-%m-%d %H:%M:%S') .. ' +0000\n'
        content = content:gsub('^(%-%-%-\n)', '%1' .. date_line)
        new_path:write(content, 'w')
        vim.cmd('edit ' .. new_path.filename)
        draft_path:rm()
        print('Draft promoted to post: ' .. new_path.filename)
      end)
      return true
    end,
  })
end

return M
