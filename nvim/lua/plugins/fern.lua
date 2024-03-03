return {
  'lambdalisue/fern.vim',
  dependencies = {
    'lambdalisue/fern-git-status.vim',
    'lambdalisue/fern-hijack.vim',
  },
  init = function()
    vim.keymap.set('n', '-', ':Fern %:h -reveal=%<CR>')
    vim.keymap.set('n', '_', ':Fern %:h -drawer -toggle -reveal=%<CR>')
  end,
}
