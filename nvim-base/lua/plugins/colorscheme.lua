return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.cmd([[colorscheme solarized]])

    require('solarized').setup({
      theme = 'neo',

      -- ensure cursor line is highlighted 
      highlights = function(colors)
        return {
          LineNr = { fg = colors.base1, bg = colors.base02 },
          CursorLineNr = { bg = colors.base02 },
          CursorLine = { bg = colors.base02 },
        }
      end
    })
  end,
}
