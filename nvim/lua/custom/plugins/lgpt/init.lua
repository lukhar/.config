local M = {}

function M.sanitize_prompt(prompt)
  if not prompt then
    return ''
  end

  -- Escape characters that are problematic in JSON strings within shell commands
  local sanitized = prompt
      :gsub('\\', '\\\\') -- Escape backslashes first
      :gsub('"', '\\"') -- Escape double quotes
      :gsub('\n', '\\n') -- Escape newlines
      :gsub('\r', '\\r') -- Escape carriage returns
      :gsub('\t', '\\t') -- Escape tabs
      :gsub('\b', '\\b') -- Escape backspace
      :gsub('\f', '\\f') -- Escape form feed
      :gsub('`', '\\`') -- Escape backticks for shell safety
      :gsub('%$', '\\$') -- Escape dollar signs for shell safety
  return sanitized
end

function M.ollama_query(options, content)
  local body = '{\\"model\\": \\"'
      .. options.model
      .. '\\", \\"messages\\": [ { \\"role\\": \\"'
      .. options.role
      .. '\\", \\"content\\": \\"'
      .. content
      .. '\\" } ], \\"stream\\": '
      .. options.stream
      .. ', \\"store\\": '
      .. options.store
      .. '}'

  local openai = 'curl -q --silent --no-buffer '
      .. '-H "Content-Type: application/json" '
      .. '-H "Authorization: Bearer '
      .. options.api_key
      .. '" '
      .. 'https://'
      .. options.host
      .. ':'
      .. options.port
      .. '/v1/chat/completions -d "'
      .. body
      .. '"'

  if options.host:match('.*openai.*') then
    return openai
  end

  local ollama = 'curl -q --silent --no-buffer -X POST '
      .. 'http://'
      .. options.host
      .. ':'
      .. options.port
      .. '/v1/chat/completions -d "'
      .. body
      .. '"'

  return ollama
end

function load_credentials()
  local raw_credentials = vim.fn.readfile('.credentials.secret')
  local credentials = vim.fn.json_decode(raw_credentials)

  return credentials['openai']['key']
end

function M.content(raw)
  local json_string = raw:match('^data:%s*(.*)') or raw
  local json = vim.fn.json_decode(json_string)

  return (json.choices[1].delta and json.choices[1].delta.content)
      or (json.choices[1].message and json.choices[1].message.content)
      or ''
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
      if not data then
        return
      end

      for _, line in ipairs(data) do
        if line ~= '' and line ~= 'data: [DONE]' then
          raw_result = raw_result .. line
        end
      end
    end,

    on_exit = function(_, _)
      local content = M.content(raw_result)
      local buffer = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content, '\n'))
      vim.api.nvim_buf_set_option(buffer, 'filetype', 'markdown')

      local width = math.min(content:len(), vim.o.columns - 100)
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
        if chunk ~= '' and chunk ~= 'data: [DONE]' then
          local content = M.content(chunk)
          local line_part = content:match('[^\n]+')
          local new_lines = content:match('[\n]+')

          if line_part then
            local line = vim.api.nvim_buf_get_lines(buffer, current_line_index, current_line_index + 1, false)[1] or ''
            vim.api.nvim_buf_set_lines(buffer, current_line_index, current_line_index + 1, false, { line .. line_part })
          end

          if new_lines then
            current_line_index = current_line_index + #new_lines
            vim.api.nvim_buf_set_lines(buffer, current_line_index, current_line_index, false, { '' })
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

  local query = M.ollama_query({
    api_key = load_credentials(),
    host = 'api.openai.com', -- localhost, api.openai.com
    port = '443',            -- 443, 11434
    model = 'gpt-4.1',       -- gpt-4o-mini, mistral
    role = 'user',
    store = 'true',
    stream = tostring(stream),
  }, M.sanitize_prompt(prompt))

  print(query)
  if stream then
    M.execute_stream_query(query)
  else
    M.execute_query(query)
  end
end, {
  bang = true,
  range = true,
  nargs = '?',
  complete = function(ArgLead) end,
})

return M
