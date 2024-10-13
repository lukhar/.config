return {
  'folke/zen-mode.nvim',
  'tpope/vim-abolish',
  'tpope/vim-commentary',
  'tpope/vim-eunuch',
  'tpope/vim-obsession',
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',
  {
    'tpope/vim-fugitive',
    init = function()
      if vim.fn.executable('hub') then
        vim.g.fugitive_git_executable = 'hub'
      end
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  'christoomey/vim-tmux-navigator',
  'junegunn/vim-slash', -- automatically disable `hlsearch`
  'mfussenegger/nvim-jdtls',
}
