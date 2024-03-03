return {
  'lambdalisue/fern.vim',
  init = function()
    vim.g.loaded_netrw = false
    vim.g.loaded_netrwPlugin = false
    vim.g.loaded_netrwSettings = false
    vim.g.loaded_netrwFileHandlers = false

    -- TODO rewrite to Lua
    vim.cmd([[
      function! s:init_fern() abort
        nmap <buffer><expr>
            \ <Plug>(fern-my-expand-or-collapse)
            \ fern#smart#leaf(
            \   "\<Plug>(fern-action-collapse)",
            \   "\<Plug>(fern-action-expand)",
            \   "\<Plug>(fern-action-collapse)",
            \ )

        nmap <buffer><nowait> l <Plug>(fern-my-expand-or-collapse)
        nmap <buffer><nowait> r <Plug>(fern-action-reload)
      endfunction

      function! s:hijack_directory() abort
        let path = expand('%:p')
        if !isdirectory(path)
          return
        endif
        bwipeout %
        execute printf('Fern %s', fnameescape(path))
      endfunction

      augroup my-fern
        autocmd! *
        autocmd FileType fern call s:init_fern()
        autocmd BufEnter * ++nested call s:hijack_directory()
      augroup END
    ]])

    vim.keymap.set('n', '-', ':Fern %:h -reveal=%<CR>')
    vim.keymap.set('n', '_', ':Fern %:h -drawer -toggle -reveal=%<CR>')
  end,
}
