-- [[ Configure LSP ]]
local function python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.fn.systemlist('pyenv which python')[1]
  end

  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

local function custom_dictionary(path)
  local spell = {}
  for word in io.open(path, 'r'):lines() do
    table.insert(spell, word)
  end
  return spell
end

local tools = { 'stylua', 'black', 'flake8' }

-- Server-specific configurations
local server_configs = {
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
  ts_ls = {},
  vimls = {},
  terraformls = {},
  ltex = {
    settings = {
      ltex = {
        dictionary = {
          ['en-US'] = custom_dictionary(vim.fn.stdpath('config') .. '/spell/en.utf-8.add'),
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
        telemetry = { enable = false },
      },
    },
  },
}

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
      'williamboman/mason-lspconfig.nvim',
      opts = {
        ensure_installed = vim.tbl_keys(server_configs),
      },
    },
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = tools,
        automatic_installation = true,
      },
    },
    { 'folke/neodev.nvim', opts = {} },
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    -- Set up neodev before configuring LSP servers
    require('neodev').setup()

    -- Get capabilities from nvim-cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Global LSP configuration for all servers
    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    -- Configure each server with server-specific settings
    for server_name, config in pairs(server_configs) do
      vim.lsp.config(
        server_name,
        vim.tbl_extend('force', {
          capabilities = capabilities,
        }, config)
      )
    end

    -- Set up LspAttach autocmd for keybindings
    -- This is the modern way to handle LSP keybindings in Neovim 0.11+
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local bufnr = event.buf

        -- Helper function for setting keymaps
        local nmap = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('gA', function()
          local current_buffer_diagnostics = vim.diagnostic.get(0)
          vim.lsp.buf.code_action({
            context = { only = { 'quickfix', 'refactor', 'source' }, diagnostics = current_buffer_diagnostics },
          })
        end, '[G]oto Code [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('gC', require('telescope.builtin').lsp_incoming_calls, '[G]oto Incoming [C]alls')
        nmap('gO', require('telescope.builtin').lsp_outgoing_calls, '[G]oto [O]utgoing Calls')
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
        local format = function()
          vim.lsp.buf.format({ async = true })
        end

        vim.api.nvim_buf_create_user_command(bufnr, 'Format', format, { desc = 'Format current buffer with LSP' })
        nmap('gF', format, '[G]o [Format] code')

        -- Toggles
        nmap('<leader>tD', function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end, 'toggle [D]iagnostics')
      end,
    })
  end,
}
