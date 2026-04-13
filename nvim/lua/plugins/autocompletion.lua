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
        local loader = require('luasnip.loaders.from_vscode')
        loader.lazy_load()

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'gitcommit',
          once = true,
          callback = function()
            loader.load({ include = { 'gitcommit' } })
          end,
        })
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
      ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
    },

    completion = {
      list = {
        selection = { preselect = true, auto_insert = false },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
    },

    sources = {
      default = { 'lsp', 'snippets', 'path' },
    },
  },
}
