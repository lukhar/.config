-- [[ Configure LSP ]]
local function python_path()
  if vim.env.VIRTUAL_ENV then
    local pyenv_root = vim.fn.systemlist('pyenv root')[1]
    local virtualenv_path =
      require('lspconfig').util.path.join(pyenv_root, 'versions', vim.env.VIRTUAL_ENV, 'bin', 'python')
    return virtualenv_path
  end

  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

local function capabilities()
  return require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

local tools = { 'stylua', 'black', 'flake8' }

local servers = {
  efm = {
    init_options = { documentFormatting = true },
    settings = {
      rootMarkers = { '.git/' },
      languages = {
        lua = {
          { formatCommand = 'stylua -', formatStdin = true, rootMarkers = { 'stylua.toml', '.stylua.toml' } },
        },
        python = {
          { formatCommand = 'isort --profile=black --quiet -', formatStdin = true },
          { formatCommand = 'black --quiet -', formatStdin = true },
          {
            lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
            lintStdin = true,
            lintIgnoreExitCode = true,
            lintFormats = { '%f:%l:%c: %m' },
          },
        },
      },
    },
  },
  gopls = {},
  pyright = {
    on_init = function(client)
      client.config.settings.python.pythonPath = python_path()
    end,
    settings = {
      python = {
        analysis = {
          -- Disable strict type checking
          typeCheckingMode = 'off',
        },
      },
    },
  },
  tsserver = {},
  vimls = {},
  terraformls = {},
  ltex = {},
  lua_ls = {
    settings = {
      Lua = {
        library = {
          [vim.fn.expand('/usr/share/awesome/lib')] = true,
        },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gA', function()
    vim.lsp.buf.code_action({ context = { only = { 'quickfix', 'refactor', 'source' } } })
  end, '[G]oto Code [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('[d', vim.diagnostic.goto_prev, 'Previous [D]iagnostic')
  nmap(']d', vim.diagnostic.goto_next, 'Next [D]iagnostic')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- colides with vim/tmux integration
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  local format = function(_)
    vim.lsp.buf.format({ async = true })
  end

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', format, { desc = 'Format current buffer with LSP' })

  nmap('gF', format, '[G]o [Format] code')
end

return {
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    {
      'williamboman/mason.nvim',
      opts = {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      },
    },
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      config = function()
        local mason_tool_installer = require('mason-tool-installer')
        local ensure_installed = vim.tbl_keys(servers)
        vim.list_extend(ensure_installed, tools)

        mason_tool_installer.setup({
          ensure_installed = ensure_installed,
          automatic_installation = true,
        })
      end,
    },
    {
      'williamboman/mason-lspconfig.nvim',

      config = function()
        require('neodev').setup()
        local lspconfig = require('lspconfig')
        local mason_lspconfig = require('mason-lspconfig')

        mason_lspconfig.setup_handlers({
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities(),
              init_options = (servers[server_name] or {}).init_options,
              on_init = (servers[server_name] or {}).on_init,
              on_attach = on_attach,
              settings = (servers[server_name] or {}).settings,
              filetypes = (servers[server_name] or {}).filetypes,
            })
          end,
        })
      end,
    },
    { 'folke/neodev.nvim', opts = {} },
    { 'j-hui/fidget.nvim', opts = {} },
  },
}
