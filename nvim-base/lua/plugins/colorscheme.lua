return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.cmd([[colorscheme solarized]])

    require('solarized').setup({
      theme = 'neo',
    })
  end,
}
