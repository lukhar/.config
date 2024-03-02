vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.background = 'dark'
vim.o.number = true
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
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,longest,preview'
-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- disable the splash screen
vim.opt.shortmess:append({ I = true })

vim.o.relativenumber = true
vim.api.nvim_create_autocmd('InsertEnter', { pattern = '*', command = 'set norelativenumber number' })
vim.api.nvim_create_autocmd('InsertLeave', { pattern = '*', command = 'set relativenumber number' })

-- enabled copying to clipboard
vim.api.nvim_set_option("clipboard","unnamed")

-- highlight on yank
-- TODO below rewrite in Lua
vim.cmd([[
  augroup highlight_yank
  autocmd!
  au TextYankPost * silent! lua vim.highlight.on_yank({timeout = 150})
  augroup END
]])

vim.o.directory = vim.fn.expand('~/.cache/nvim/swp/')
vim.o.undodir = vim.fn.expand('~/.cache/nvim/undo/')

-- set pop up menu to have fixed length
vim.o.pumheight = 35

-- wildmenu
vim.o.wildmenu = true
vim.opt.wildignore:append { '*.a', '*.o', '*.pyc' }
vim.opt.wildignore:append { '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png' }
vim.opt.wildignore:append { '*~', '*.swp', '*.tmp' }
vim.opt.wildmode = 'longest:full,full'

-- Dim inactive panes
-- TODO below rewrite in Lua
vim.cmd([[
  hi ActiveWindow guibg=None
  hi InactiveWindow guibg=#073642

  " Call method on window enter
  augroup WindowManagement
    autocmd!
    autocmd WinEnter * call HandleWinEnter()
    autocmd FocusLost * call FocusLostInactive()
    autocmd FocusGained * call FocusGainedActive()
  augroup END

  " Change highlight group of active/inactive windows
  function! HandleWinEnter()
    setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
  endfunction

  " Change color when focus lost
  function! FocusLostInactive()
    setlocal winhighlight=Normal:InactiveWindow,NormalNC:InactiveWindow
  endfunction

  " Change color when focus gained
  function! FocusGainedActive()
    setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow
  endfunction
]])

-- manage sessions in projects
vim.cmd([[
  augroup SessionManagment
  autocmd VimEnter * call OpenSession()
  augroup END

  function! OpenSession()
    if isdirectory(".git")
      execute ":Mkdir! .vim"
      execute ":Obsession .vim/session.vim"
    end
  endfunction
]])
