vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.background = 'dark'
vim.o.showmatch = true
vim.o.expandtab = true
vim.o.incsearch = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.backspace = 'indent,eol,start'
vim.o.showmode = true
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

-- set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,longest,preview'
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

-- set pop up menu to have fixed length
vim.o.pumheight = 35

-- display whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- wildmenu
vim.o.wildmenu = true
vim.opt.wildignore:append({ '*.a', '*.o', '*.pyc' })
vim.opt.wildignore:append({ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png' })
vim.opt.wildignore:append({ '*~', '*.swp', '*.tmp' })
vim.opt.wildmode = 'longest:full,full'

-- use faster grepping tools if available
if vim.fn.executable('ag') then
  vim.opt.grepprg = 'ag --nogroup --nocolor'
  vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end

if vim.fn.executable('rg') then
  vim.opt.grepprg = 'rg --vimgrep --no-heading'
  vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end

-- reload configuration
local function reload_config()
  local reload = require('plenary.reload').reload_module
  reload('config.options', false)
  reload('config.keymaps', false)
  reload('config.plugins', false)
  reload('config.globals', false)

  dofile(vim.env.MYVIMRC)
end

vim.keymap.set('n', '<leader>R', reload_config, { desc = '[R]eload Configuration' })

-- dim inactive panes
local window_managment = vim.api.nvim_create_augroup('window_managment', { clear = true })
local solarized_dark_base02 = '#073642'

vim.api.nvim_set_hl(0, 'ActiveWindow', { bg = '' })
vim.api.nvim_set_hl(0, 'InactiveWindow', { bg = solarized_dark_base02 })

vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  group = window_managment,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = '' })
  end,
})

vim.api.nvim_create_autocmd({ 'FocusLost' }, {
  group = window_managment,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:InactiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = solarized_dark_base02 })
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained' }, {
  group = window_managment,
  callback = function()
    vim.opt_local.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = '' })
  end,
})

-- manage sessions in projects
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('session_managment', { clear = true }),
  callback = function()
    if vim.fn.isdirectory('.git') then
      vim.fn.mkdir('.vim/', 'p')
      vim.fn.execute(':Obsession .vim/session.vim')
    end
  end,
})

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
