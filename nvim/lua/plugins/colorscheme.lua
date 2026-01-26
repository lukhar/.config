return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  version = 'v3.6.0',
  config = function()
    vim.o.background = 'dark'
    vim.cmd([[colorscheme solarized]])
    vim.cmd([[
      nm <silent> <F2> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
          \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
          \ . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
          \ . ">"<CR>
    ]])

    require('solarized').setup({
      highlights = function(colors)
        return {
          LineNr = { fg = colors.base1, bg = colors.base02 },
          CursorLineNr = { bg = colors.base02 },
          CursorLine = { bg = colors.base02 },
          Visual = { fg = colors.base03, bg = colors.base01 },
          CurSearch = { fg = colors.base03, bg = colors.orange },
          Search = { fg = colors.base03, bg = colors.change },
          diffAdded = { fg = colors.hint },
          diffChanged = { fg = colors.warning },
          diffRemoved = { fg = colors.delete },
          diffLine = { fg = colors.info },
          diffSubname = { fg = colors.orange },
          fugitiveUnstagedHeading = { fg = colors.orange },
          fugitiveStagedHeading = { fg = colors.orange },
          fugitiveHeading = { fg = colors.orange },
        }
      end,
    })
  end,
}
