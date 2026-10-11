return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  version = 'v3.6.0',
  config = function()
    vim.o.background = 'dark'
    vim.cmd([[colorscheme solarized]])
    vim.keymap.set('n', '<F2>', '<cmd>Inspect<cr>', { desc = 'Show highlight groups under cursor' })
  end,
}
