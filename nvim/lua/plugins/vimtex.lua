  return {
    'lervag/vimtex',
    init = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_format_enalbed = true
      vim.g.vimtex_fold_enabled = true
      if vim.fn.has('unix') then
        if vim.fn.has('mac') then
          vim.g.vimtex_view_method = 'skim'
        else
          vim.g.vimtex_view_method = 'zathura'
        end
      end
    end
  }
