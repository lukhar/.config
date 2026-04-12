return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local palette = require('solarized.palette')

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end

    local sections = {}

    local icons = {
      vim = '',
      git = '',
      diff = { added = '󰐕', modified = '~', removed = '󰍴' },
      default = { left = '', right = ' ' },
      round = { left = '', right = '' },
      block = { left = '█', right = '█' },
      arrow = { left = '', right = '' },
    }

    local function ins_config(location, component)
      sections['lualine_' .. location] = component
    end

    local function resolve_icon(filename)
      local icon = '󰈚'

      local devicons_present, devicons = pcall(require, 'nvim-web-devicons')

      if devicons_present then
        local ft_icon = devicons.get_icon(filename)
        icon = (ft_icon ~= nil and ft_icon) or icon
      end

      return icon
    end

    local function resolve_filepath()
      local filepath = vim.fn.expand('%')

      if filepath:sub(1, 6) == 'jdt://' then
        return filepath:gsub('?.*$', '')
      end

      return filepath
    end

    ins_config('a', {
      {
        'mode',
        icon = icons.vim,
        separator = { left = icons.block.left, right = icons.default.right },
        right_padding = 2,
      },
    })

    ins_config('b', {
      {
        'filename',
        fmt = function(filename)
          local filepath = resolve_filepath()
          local icon = resolve_icon(filename)
          return string.format('%s %s', icon, filepath)
        end,
      },
    })

    ins_config('c', {
      {
        'branch',
        icon = { icons.git, color = { fg = palette.magenta or '#d33682' } },
        cond = hide_in_width,
      },
      {
        'diff',
        symbols = icons.diff,
        colored = true,
        diff_color = {
          added = { fg = palette.green or '#859900' },
          modified = { fg = palette.orange or '#cb4b16' },
          removed = { fg = palette.red or '#dc322f' },
        },
        cond = hide_in_width,
      },
    })

    ins_config('x', {})

    ins_config('y', {
      {
        'progress',
        fmt = function(progress)
          local spinners = { '󰚀', '󰪞', '󰪠', '󰪡', '󰪢', '󰪣', '󰪤', '󰚀' }

          if string.match(progress, '%a+') then
            return progress
          end

          local p = tonumber(string.match(progress, '%d+'))

          if p ~= nil then
            local index = math.floor(p / (100 / #spinners)) + 1
            return '  ' .. spinners[index]
          end
        end,
        separator = { left = icons.default.left },
        cond = hide_in_width,
      },
      {
        'location',
        cond = hide_in_width,
      },
    })

    ins_config('z', {
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          local names = {}
          for _, client in ipairs(clients) do
            if client.name ~= 'null-ls' then
              table.insert(names, client.name)
            end
          end
          return #names > 0 and table.concat(names, '|') or 'No Active Lsp'
        end,
      },
    })

    require('lualine').setup({
      options = {
        component_separators = '',
        section_separators = { left = icons.default.right, right = icons.default.left },
        disabled_filetypes = {
          'NvimTree',
          'starter',
        },
        refresh = {
          statusline = 1000,
        },
      },
      sections = sections,
      inactive_sections = {
        lualine_a = {
          {
            'filename',
            fmt = function(filename)
              local filepath = resolve_filepath()
              local icon = resolve_icon(filename)
              return string.format('%s %s', icon, vim.fn.pathshorten(filepath))
            end,
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
      },
    })
  end,
}
