return {
  'lambdalisue/fern.vim',
  dependencies = {
    'lambdalisue/fern-git-status.vim',
    'lambdalisue/fern-hijack.vim',
    'lambdalisue/nerdfont.vim',
    'lambdalisue/fern-renderer-nerdfont.vim',
    'lambdalisue/glyph-palette.vim',
  },
  init = function()
    vim.g['fern#hide_cursor'] = 1
    vim.g['fern#default_hidden'] = 1
    vim.g['fern#renderer'] = 'nerdfont'
    vim.keymap.set('n', '-', ':Fern %:h -reveal=%<CR>')
    vim.keymap.set('n', '_', ':Fern %:h -drawer -toggle -reveal=%<CR>')
  end,
  config = function()
    vim.api.nvim_create_autocmd({'FileType'}, {
      group = vim.api.nvim_create_augroup('glyph_palette', {clear = true}),
      pattern = 'fern',
      callback = function()
        vim.opt_local.signcolumn = 'no'
        vim.fn['glyph_palette#apply']()
      end,
    })
  end,
}
