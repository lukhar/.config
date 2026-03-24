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
  end,
}
