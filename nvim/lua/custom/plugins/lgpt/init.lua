local M = {}

function M.ollama_query(options, content)
  local body = '{\\"model\\": \\"'
    .. options.model
    .. '\\", \\"messages\\": [ { \\"role\\": \\"'
    .. options.role
    .. '\\", \\"content\\": \\"'
    .. content
    .. '\\" } ], \\"stream\\": '
    .. options.stream
    .. '}'
  return 'curl -q --silent --no-buffer -X POST http://'
    .. options.host
    .. ':'
    .. options.port
    .. '/api/chat -d "'
    .. body
    .. '"'
end

function M.open_window(buffer, width, height)
  local ui = vim.api.nvim_list_uis()[1]
  local row = (ui.height - height) / 2
  local col = (ui.width - width) / 2

  local window = vim.api.nvim_open_win(buffer, true, {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
  })

  vim.api.nvim_set_current_win(window)

  vim.api.nvim_create_autocmd('WinLeave', {
    pattern = '<buffer>',
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
    end,
  })

  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(window) then
      vim.api.nvim_win_close(window, true)
    end
  end, { buffer = buffer, nowait = true, silent = true })
end

function M.execute_query(query)
  local raw_result = ''

  vim.fn.jobstart(query, {
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        raw_result = raw_result .. line
      end
    end,

    on_exit = function(_, _)
      local result = vim.fn.json_decode(raw_result)

      local buffer = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(result.message.content, '\n'))
      vim.api.nvim_buf_set_option(buffer, 'filetype', 'markdown')

      local width = math.min(#result.message.content, vim.o.columns - 100)
      local height = math.max(2, vim.api.nvim_buf_line_count(buffer))

      M.open_window(buffer, width, height)
    end,
  })
end

function M.execute_stream_query(query)
  local buffer = vim.api.nvim_create_buf(false, true)
  local current_line_index = 0

  -- Calculate dimensions (80% of screen size)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  M.open_window(buffer, width, height)

  vim.fn.jobstart(query, {
    stdout_buffered = false,
    stderr_buffered = true,

    on_stdout = function(_, data, _)
      if not data then
        return
      end

      for _, chunk in ipairs(data) do
        if chunk ~= '' then
          local content = vim.fn.json_decode(chunk).message.content
          if content == '\n' then
            current_line_index = current_line_index + 1
            vim.api.nvim_buf_set_lines(buffer, current_line_index, current_line_index, false, { '' })
          else
            local line = vim.api.nvim_buf_get_lines(buffer, current_line_index, current_line_index + 1, false)[1] or ''
            vim.api.nvim_buf_set_lines(buffer, current_line_index, current_line_index + 1, false, { line .. content })
          end
        end
      end
    end,

    on_stderr = function(_, data, _)
      for _, chunk in ipairs(data) do
        if chunk ~= '' then
          vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { '[stderr] ' .. chunk })
        end
      end
    end,

    on_exit = function()
      vim.api.nvim_buf_set_option(buffer, 'filetype', 'markdown')
    end,
  })
end

vim.api.nvim_create_user_command('Lgen', function(input)
  local mode = (input.range == 0 and 'n') or 'v'
  local stream = not input.bang
  local prompt

  if mode == 'n' then
    prompt = input.args
  elseif mode == 'v' then
    local prefix = input.args or ''
    local lines = vim.api.nvim_buf_get_lines(0, input.line1 - 1, input.line2, false)
    prompt = prefix .. ':\\n' .. table.concat(lines, '\\n')
  end

  local query = M.ollama_query(
    { host = 'localhost', port = '11434', model = 'mistral', role = 'user', stream = tostring(stream) },
    prompt:gsub('`', '')
  )

  if stream then
    M.execute_stream_query(query)
  else
    M.execute_query(query)
  end
  -- M.open_popup_and_stream()
end, {
  bang = true,
  range = true,
  nargs = '?',
  complete = function(ArgLead) end,
})

return M
