return {
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    opts = {
      window = {
        options = {
          number = false,
          relativenumber = false,
        },
      },
    },
  },
  { 'tpope/vim-abolish', cmd = { 'S', 'Abolish' } },
  { 'tpope/vim-commentary', keys = { { 'gc', mode = { 'n', 'v' } }, 'gcc' } },
  { 'tpope/vim-eunuch', cmd = { 'Move', 'Rename', 'Delete', 'SudoWrite', 'Chmod', 'Mkdir' } },
  { 'tpope/vim-obsession', cmd = 'Obsession' },
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth', event = 'BufReadPost' },
  { 'tpope/vim-surround', keys = { 'ys', 'cs', 'ds', { 'S', mode = 'v' } } },
  { 'tpope/vim-unimpaired', event = 'VeryLazy' },
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G' },
    init = function()
      if vim.fn.executable('hub') then
        vim.g.fugitive_git_executable = 'hub'
      end
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
    enabled = not vim.g.vscode,
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'christoomey/vim-tmux-navigator',
    -- Mapping the keys straight to the commands, rather than listing bare key
    -- strings, removes lazy's replay step: with `keys = { '<C-h>', ... }` lazy
    -- installs a stub, loads the plugin on press and then feeds the key again,
    -- hoping the plugin's own mapping is in place by then. This is unambiguous
    -- whether the plugin has loaded or not.
    cmd = { 'TmuxNavigateLeft', 'TmuxNavigateDown', 'TmuxNavigateUp', 'TmuxNavigateRight' },
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>' },
    },
  },

  { 'mfussenegger/nvim-jdtls', ft = 'java' },
  {
    'ludovicchabant/vim-gutentags',
    event = 'VeryLazy',
    init = function()
      vim.g.gutentags_cache_dir = vim.fn.expand('~/.cache/nvim/tags')
      vim.g.gutentags_ctags_exclude = { 'target', '.git', '*.class', '*.pyc', '__pycache__', 'docs', 'node_modules' }
      vim.g.gutentags_file_list_command = 'git ls-files'
    end,
  },
}
