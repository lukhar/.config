return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        if vim.fn.has('win32') == 1 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },
    'rafamadriz/friendly-snippets',
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    snippets = { preset = 'luasnip' },

    keymap = {
      preset = 'enter',
      ['<Space>'] = { 'accept', 'fallback' },
    },

    completion = {
      list = {
        selection = { preselect = true, auto_insert = true },
      },
    },

    sources = {
      default = { 'lsp', 'snippets', 'path' },
    },
  },
}
