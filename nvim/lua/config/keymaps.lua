vim.keymap.set({ 'n', 'v' }, 'cp', 'y"+')

-- use jk/kj to enter normal mode
vim.keymap.set({ 'i' }, 'jk', '<Esc>')
vim.keymap.set({ 'i' }, 'kj', '<Esc>')

-- file opening through partial matching (nested in directories or over path)
vim.keymap.set({ 'n' }, ';e', ':e **/*')
vim.keymap.set({ 'n' }, ';f', ':find **/*')
vim.keymap.set({ 'c' }, 'eE', 'e **/*')
vim.keymap.set({ 'c' }, 'fF', 'find **/*')

-- maps Alt-[h,j,k,l] to resizing a window split
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>2<', { silent = true })
vim.keymap.set({ 'n' }, '<A-j>', '<C-W>2-', { silent = true })
vim.keymap.set({ 'n' }, '<A-k>', '<C-W>2+', { silent = true })
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>2>', { silent = true })

-- numbered search results for easier navigation
vim.keymap.set({ 'n' }, '//', ':g//#<Left><Left>')

-- disable highlight search with esc key
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
