local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace = '~/.cache/jdtls/workspace/' .. project_name

local config = {
  cmd = { vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls'), '-data', workspace ,  '-Xmx20g'},
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)
