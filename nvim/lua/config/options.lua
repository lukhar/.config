vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.showmatch = true
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.backspace = 'indent,eol,start'
vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.autoread = true
vim.o.cursorline = true
vim.o.laststatus = 2
vim.o.hidden = true
vim.o.mouse = 'a'
vim.o.splitright = true
vim.o.scrolloff = 10

vim.o.termguicolors = true

-- disable the splash screen
vim.opt.shortmess:append({ I = true })

-- custom dictionary
vim.opt.spellfile = vim.fn.stdpath('config') .. '/spell/en.utf-8.add'

-- smart relative numbers
vim.o.number = true
vim.o.relativenumber = true
vim.api.nvim_create_autocmd('InsertEnter', { pattern = '*', command = 'set norelativenumber number' })
vim.api.nvim_create_autocmd('InsertLeave', { pattern = '*', command = 'set relativenumber number' })

-- wrapped lines match indentation
vim.o.breakindent = true
vim.o.breakindentopt = 'shift:2'

-- enabled copying to clipboard
vim.opt.clipboard = 'unnamed'

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
  group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
})

vim.o.directory = vim.fn.expand('~/.cache/nvim/swp/')
vim.o.undodir = vim.fn.expand('~/.cache/nvim/undo/')
vim.fn.mkdir(vim.fn.expand('~/.cache/nvim/swp/'), 'p')
vim.fn.mkdir(vim.fn.expand('~/.cache/nvim/undo/'), 'p')

-- set pop up menu to have fixed length
vim.o.pumheight = 35

-- display whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- ctags
vim.opt.tags = { './tags', './.git/tags', 'tags', '.vim/tags' }

-- wildmenu
vim.o.wildmenu = true
vim.opt.wildignore:append({ '*.a', '*.o', '*.pyc' })
vim.opt.wildignore:append({ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png' })
vim.opt.wildignore:append({ '*~', '*.swp', '*.tmp' })
vim.opt.wildmode = 'longest:full,full'

-- use faster grepping tools if available
if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = 'rg --vimgrep --no-heading'
  vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
elseif vim.fn.executable('ag') == 1 then
  vim.opt.grepprg = 'ag --nogroup --nocolor'
  vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end

-- reload configuration
local function reload_config()
  local reload = require('plenary.reload').reload_module
  reload('config.options', false)
  reload('config.keymaps', false)
  reload('globals', false)

  dofile(vim.env.MYVIMRC)
end

vim.keymap.set('n', '<leader>R', reload_config, { desc = '[R]eload Configuration' })

-- dim inactive panes
local window_management = vim.api.nvim_create_augroup('window_management', { clear = true })
local solarized_dark_base02 = '#073642'

vim.api.nvim_set_hl(0, 'ActiveWindow', { bg = '' })
vim.api.nvim_set_hl(0, 'InactiveWindow', { bg = solarized_dark_base02 })

vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  group = window_management,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = '' })
  end,
})

vim.api.nvim_create_autocmd({ 'FocusLost' }, {
  group = window_management,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:InactiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = solarized_dark_base02 })
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained' }, {
  group = window_management,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = '' })
  end,
})

-- manage sessions in projects
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('session_management', { clear = true }),
  callback = function()
    if vim.fn.isdirectory('.git') then
      vim.fn.mkdir('.vim/', 'p')
      vim.cmd('Obsession .vim/session.vim')
    end
  end,
})

---@param remote string git remote URL (SSH or HTTPS)
---@param file_dir string directory of the current buffer
---@return string|nil url GitHub permalink or nil if remote can't be parsed
local function github_url(remote, file_dir)
  local host, path = remote:match('^git@([^:]+):(.+)$')

  if not host then
    host, path = remote:match('^https?://([^/]+)/(.+)$')
  end

  if not host or not path then
    return
  end

  path = path:gsub('%.git$', '')
  local root = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { cwd = file_dir }):wait().stdout:gsub('%s+$', '')
  local ref = vim.system({ 'git', 'rev-parse', 'HEAD' }, { cwd = file_dir }):wait().stdout:gsub('%s+$', '')
  local file = vim.api.nvim_buf_get_name(0):sub(#root + 2)
  local line, _ = unpack(vim.api.nvim_win_get_cursor(0))

  return ('https://%s/%s/blob/%s/%s#L%d'):format(host, path, ref, file, line)
end

vim.keymap.set('n', '<leader>gl', function()
  local file_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local result = vim.system({ 'git', 'remote', 'get-url', 'origin' }, { cwd = file_dir }):wait()

  if result.code ~= 0 then
    vim.notify('Not a git repository', vim.log.levels.WARN)
    return
  end

  local remote = result.stdout:gsub('%s+$', '')

  local url = github_url(remote, file_dir)

  if not url then
    vim.notify('Could not parse remote: ' .. remote, vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', url)
  vim.notify("Copied " .. url:sub(0, vim.api.nvim_win_get_width(0) - 5))
end, { desc = 'Get [G]ithub [L]ink to this line' })

-- fancy diagnostics symbols
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
})
