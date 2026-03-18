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
  { 'tpope/vim-abolish',    cmd = { 'S', 'Abolish' } },
  { 'tpope/vim-commentary', keys = { { 'gc', mode = { 'n', 'v' } }, 'gcc' } },
  { 'tpope/vim-eunuch',     cmd = { 'Move', 'Rename', 'Delete', 'SudoWrite', 'Chmod', 'Mkdir' } },
  { 'tpope/vim-obsession',  cmd = 'Obsession' },
  { 'tpope/vim-repeat',     event = 'VeryLazy' },
  { 'tpope/vim-sleuth',     event = 'BufReadPre' },
  { 'tpope/vim-surround',   keys = { 'ys', 'cs', 'ds', { 'S', mode = 'v' } } },
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
    keys = { '<C-h>', '<C-j>', '<C-k>', '<C-l>' },
  },
  { 'junegunn/vim-slash', event = 'VeryLazy' }, -- automatically disable `hlsearch`
  { 'mfussenegger/nvim-jdtls', ft = 'java' },
}
