return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  event = 'BufReadPost',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup({})

    -- ensure parsers are installed
    local installed = require('nvim-treesitter').get_installed()
    local ensure_installed = {
      'bash',
      'c',
      'cpp',
      'dockerfile',
      'go',
      'groovy',
      'java',
      'javascript',
      'json',
      'lua',
      'markdown',
      'python',
      'rust',
      'scala',
      'sql',
      'toml',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    }
    local to_install = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure_installed)
    if #to_install > 0 then
      require('nvim-treesitter').install(to_install)
    end

    -- highlight and indent are built into Neovim 0.12+, enable per buffer
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })

    -- incremental selection
    vim.keymap.set('n', '<c-space>', function()
      vim.treesitter.incremental_selection.init_selection()
    end)
    vim.keymap.set('x', '<c-space>', function()
      vim.treesitter.incremental_selection.node_incremental()
    end)
    vim.keymap.set('x', '<c-s>', function()
      vim.treesitter.incremental_selection.scope_incremental()
    end)
    vim.keymap.set('x', '<M-space>', function()
      vim.treesitter.incremental_selection.node_decremental()
    end)

    -- textobjects
    local select = require('nvim-treesitter-textobjects.select')
    local move = require('nvim-treesitter-textobjects.move')
    local swap = require('nvim-treesitter-textobjects.swap')

    require('nvim-treesitter-textobjects').setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    -- select keymaps
    for lhs, query in pairs({
      ['aa'] = '@parameter.outer',
      ['ia'] = '@parameter.inner',
      ['af'] = '@function.outer',
      ['if'] = '@function.inner',
      ['ac'] = '@class.outer',
      ['ic'] = '@class.inner',
    }) do
      vim.keymap.set({ 'x', 'o' }, lhs, function()
        select.select_textobject(query)
      end)
    end

    -- move keymaps
    for lhs, query in pairs({
      [']m'] = '@function.outer',
      [']]'] = '@class.outer',
    }) do
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        move.goto_next_start(query)
      end)
    end
    for lhs, query in pairs({
      [']M'] = '@function.outer',
      [']['] = '@class.outer',
    }) do
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        move.goto_next_end(query)
      end)
    end
    for lhs, query in pairs({
      ['[m'] = '@function.outer',
      ['[['] = '@class.outer',
    }) do
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        move.goto_previous_start(query)
      end)
    end
    for lhs, query in pairs({
      ['[M'] = '@function.outer',
      ['[]'] = '@class.outer',
    }) do
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        move.goto_previous_end(query)
      end)
    end

    -- swap keymaps
    vim.keymap.set('n', '<leader>a', function()
      swap.swap_next('@parameter.inner')
    end)
    vim.keymap.set('n', '<leader>A', function()
      swap.swap_previous('@parameter.inner')
    end)
  end,
}
