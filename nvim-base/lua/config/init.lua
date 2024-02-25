vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_python_provider = 0
vim.g.python3_host_prog = '~/.pyenv/versions/neovim/bin/python'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local options = {
  defaults = {
    lazy = false,
  },
  install = {
    colorscheme = { 'solarized' },
  },
  rtp = {
    disabled_plugins = {
      'gzip',
      'matchit',
      'matchparen',
      'netrw',
      'netrwPlugin',
      'tarPlugin',
      'tohtml',
      'tutor',
      'zipPlugin',
    },
  },
  change_detection = {
    notify = false,
  },
}

require('lazy').setup('plugins', options)
