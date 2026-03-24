return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    -- document existing key chains
    local which_key = require('which-key')

    which_key.setup({
      layout = {
        align = 'center',
      },
    })

    which_key.add({
      { '<leader>d', group = '[D]ocument' },
      { '<leader>g', group = '[G]it' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    })
  end,
}
