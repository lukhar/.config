local M = {}

local providers = require('custom.plugins.vibr.providers')

---@class VibrMessage
---@field role "user"|"assistant"|"system"
---@field content string

---@class VibrRequest
---@field url string
---@field method string
---@field headers table<string, string>
---@field body string

---@param request VibrRequest
---@return string[]
function M.to_curl(request)
  local cmd = { 'curl', '-q', '--silent', '--no-buffer', '-X', request.method }

  for key, value in pairs(request.headers) do
    table.insert(cmd, '-H')
    table.insert(cmd, key .. ': ' .. value)
  end

  table.insert(cmd, request.url)
  table.insert(cmd, '-d')
  table.insert(cmd, request.body)

  return cmd
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

---@param request VibrRequest
---@param buffer integer
---@param provider VibrProvider
function M.execute(request, buffer, provider)
  local cmd = M.to_curl(request)
  local current_line_index = 0

  local stdout = vim.uv.new_pipe(false)
  local stderr = vim.uv.new_pipe(false)

  if not stdout or not stderr then
    if stdout then stdout:close() end
    if stderr then stderr:close() end
    vim.notify('Failed to create pipes', vim.log.levels.ERROR)
    return
  end

  ---@diagnostic disable-next-line: missing-fields
  vim.uv.spawn(cmd[1], {
    args = vim.list_slice(cmd, 2),
    stdio = { nil, stdout, stderr },
  }, function(code, _)
    stdout:close()
    stderr:close()
    vim.schedule(function()
      vim.api.nvim_set_option_value('filetype', 'markdown', {buf = buffer})
      if code ~= 0 then
        vim.notify('Stream process exited with code: ' .. code, vim.log.levels.WARN)
      end
      if opts.on_complete then
        opts.on_complete(full_response)
      end
    end)
  end)

  stdout:read_start(function(error, data)
    if error then
      vim.schedule(function()
        vim.notify('stdout error: ' .. error, vim.log.levels.ERROR)
      end)
      return
    end

    if not data then
      return
    end

    vim.schedule(function()
      for chunk in data:gmatch('[^\r\n]+') do
        if chunk ~= '' and chunk ~= 'data: [DONE]' then
          local content = provider.parse_chunk(chunk)
          if content and content ~= '' then
            full_response = full_response .. content

            if opts.on_chunk then
              opts.on_chunk(content)
            end

            local line_part = content:match('[^\n]+')
            local new_lines = content:match('[\n]+')

            if line_part then
              local line = vim.api.nvim_buf_get_lines(buffer, current_line_index, current_line_index + 1, false)[1]
                or ''
              vim.api.nvim_buf_set_lines(
                buffer,
                current_line_index,
                current_line_index + 1,
                false,
                { line .. line_part }
              )
            end

            if new_lines then
              current_line_index = current_line_index + #new_lines
              vim.api.nvim_buf_set_lines(buffer, current_line_index, current_line_index, false, { '' })
            end
          end
        end
      end
    end)
  end)

  stderr:read_start(function(error, data)
    if error then
      vim.schedule(function()
        vim.notify('stderr error: ' .. error, vim.log.levels.ERROR)
      end)
      return
    end

    if data then
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { '[stderr] ' .. data })
      end)
    end
  end)
end

-- Render chat messages to the chat buffer
function M.render_chat()
  if not M.chat.buffer or not vim.api.nvim_buf_is_valid(M.chat.buffer) then
    return
  end

  local lines = {}
  for _, msg in ipairs(M.chat.messages) do
    if msg.role == 'user' then
      table.insert(lines, '## You')
    else
      table.insert(lines, '## Assistant')
    end
    table.insert(lines, '')
    for _, line in ipairs(vim.split(msg.content, '\n')) do
      table.insert(lines, line)
    end
    table.insert(lines, '')
  end

  vim.api.nvim_set_option_value('modifiable', true, { buf = M.chat.buffer })
  vim.api.nvim_buf_set_lines(M.chat.buffer, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = M.chat.buffer })

  -- Scroll to bottom
  if M.chat.window and vim.api.nvim_win_is_valid(M.chat.window) then
    local line_count = vim.api.nvim_buf_line_count(M.chat.buffer)
    vim.api.nvim_win_set_cursor(M.chat.window, { line_count, 0 })
  end
end

-- Open the chat UI
function M.open_chat()
  local provider = providers.get()
  if not provider then
    vim.notify('Vibr: no provider configured', vim.log.levels.ERROR)
    return
  end

  local api_key = provider.load_credentials()
  if not api_key then
    return
  end

  M.chat.provider = provider
  M.chat.api_key = api_key

  -- Create or reuse chat history buffer
  if not M.chat.buffer or not vim.api.nvim_buf_is_valid(M.chat.buffer) then
    M.chat.buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M.chat.buffer })
    vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = M.chat.buffer })
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = M.chat.buffer })
    vim.api.nvim_set_option_value('modifiable', false, { buf = M.chat.buffer })
    vim.api.nvim_buf_set_name(M.chat.buffer, '[Vibr Chat]')

    vim.keymap.set('n', 'q', M.close_chat, { buffer = M.chat.buffer, nowait = true, silent = true })
  end

  -- Create or reuse input buffer
  if not M.chat.input_buffer or not vim.api.nvim_buf_is_valid(M.chat.input_buffer) then
    M.chat.input_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M.chat.input_buffer })
    vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = M.chat.input_buffer })
    vim.api.nvim_buf_set_name(M.chat.input_buffer, '[Vibr Input]')

    vim.keymap.set('n', '<CR>', M.send_message, { buffer = M.chat.input_buffer, nowait = true, silent = true })
    vim.keymap.set('i', '<C-CR>', function()
      vim.cmd('stopinsert')
      M.send_message()
    end, { buffer = M.chat.input_buffer, nowait = true, silent = true })
    vim.keymap.set('n', 'q', M.close_chat, { buffer = M.chat.input_buffer, nowait = true, silent = true })
  end

  -- Calculate dimensions (40% width on right side)
  local width = math.floor(vim.o.columns * 0.4)
  local input_height = 3

  -- Open vertical split on right for chat history
  vim.cmd('botright vsplit')
  M.chat.window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.chat.window, M.chat.buffer)
  vim.api.nvim_win_set_width(M.chat.window, width)
  vim.api.nvim_set_option_value('wrap', true, { win = M.chat.window })
  vim.api.nvim_set_option_value('linebreak', true, { win = M.chat.window })
  vim.api.nvim_set_option_value('number', false, { win = M.chat.window })
  vim.api.nvim_set_option_value('relativenumber', false, { win = M.chat.window })
  vim.api.nvim_set_option_value('signcolumn', 'no', { win = M.chat.window })

  -- Split at bottom for input
  vim.cmd('belowright split')
  M.chat.input_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M.chat.input_window, M.chat.input_buffer)
  vim.api.nvim_win_set_height(M.chat.input_window, input_height)
  vim.api.nvim_set_option_value('wrap', true, { win = M.chat.input_window })
  vim.api.nvim_set_option_value('number', false, { win = M.chat.input_window })
  vim.api.nvim_set_option_value('relativenumber', false, { win = M.chat.input_window })
  vim.api.nvim_set_option_value('signcolumn', 'no', { win = M.chat.input_window })

  -- Render existing messages
  M.render_chat()

  -- Focus input window and enter insert mode
  vim.api.nvim_set_current_win(M.chat.input_window)
  vim.cmd('startinsert')
end

-- Close the chat UI
function M.close_chat()
  if M.chat.window and vim.api.nvim_win_is_valid(M.chat.window) then
    vim.api.nvim_win_close(M.chat.window, true)
  end
  if M.chat.input_window and vim.api.nvim_win_is_valid(M.chat.input_window) then
    vim.api.nvim_win_close(M.chat.input_window, true)
  end
  M.chat.window = nil
  M.chat.input_window = nil
end

-- Toggle the chat UI
function M.toggle_chat()
  if M.chat.window and vim.api.nvim_win_is_valid(M.chat.window) then
    M.close_chat()
  else
    M.open_chat()
  end
end

-- Send a message from the input buffer
function M.send_message()
  if not M.chat.input_buffer or not vim.api.nvim_buf_is_valid(M.chat.input_buffer) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(M.chat.input_buffer, 0, -1, false)
  local content = vim.trim(table.concat(lines, '\n'))

  if content == '' then
    return
  end

  -- Clear input buffer
  vim.api.nvim_buf_set_lines(M.chat.input_buffer, 0, -1, false, {})

  -- Append user message to history
  table.insert(M.chat.messages, { role = 'user', content = content })

  -- Render chat (shows user message immediately)
  M.render_chat()

  -- Build request with full messages array
  local request = M.chat.provider.build_request(M.chat.messages, {
    api_key = M.chat.api_key,
    store = true,
  })

  -- Stream response
  M.stream_chat_response(request)
end

-- Stream response to chat buffer
function M.stream_chat_response(request)
  -- Make buffer modifiable for streaming
  vim.api.nvim_set_option_value('modifiable', true, { buf = M.chat.buffer })

  -- Add placeholder for assistant response
  local line_count = vim.api.nvim_buf_line_count(M.chat.buffer)
  vim.api.nvim_buf_set_lines(M.chat.buffer, line_count, line_count, false, { '## Assistant', '', '' })

  local response_start_line = line_count + 2

  M.execute(request, M.chat.buffer, M.chat.provider, {
    start_line = response_start_line,
    on_chunk = function(_)
      -- Scroll to bottom on each chunk
      if M.chat.window and vim.api.nvim_win_is_valid(M.chat.window) then
        local total_lines = vim.api.nvim_buf_line_count(M.chat.buffer)
        vim.api.nvim_win_set_cursor(M.chat.window, { total_lines, 0 })
      end
    end,
    on_complete = function(response)
      table.insert(M.chat.messages, { role = 'assistant', content = response })
      -- Add blank line after response and lock buffer
      local final_line_count = vim.api.nvim_buf_line_count(M.chat.buffer)
      vim.api.nvim_buf_set_lines(M.chat.buffer, final_line_count, final_line_count, false, { '' })
      vim.api.nvim_set_option_value('modifiable', false, { buf = M.chat.buffer })
    end,
  })
end

-- Clear chat history
function M.clear_chat()
  M.chat.messages = {}
  if M.chat.buffer and vim.api.nvim_buf_is_valid(M.chat.buffer) then
    vim.api.nvim_set_option_value('modifiable', true, { buf = M.chat.buffer })
    vim.api.nvim_buf_set_lines(M.chat.buffer, 0, -1, false, {})
    vim.api.nvim_set_option_value('modifiable', false, { buf = M.chat.buffer })
  end
  vim.notify('Vibr: chat cleared', vim.log.levels.INFO)
end

-- Chat commands
vim.api.nvim_create_user_command('VibrChat', M.toggle_chat, {})
vim.api.nvim_create_user_command('VibrClear', M.clear_chat, {})

vim.api.nvim_create_user_command('Vibr', function(input)
  local provider = providers.get()
  if not provider then
    vim.notify('Vibr: no provider configured', vim.log.levels.ERROR)
    return
  end

  local mode = (input.range == 0 and 'n') or 'v'
  local prompt

  if mode == 'n' then
    prompt = input.args
  elseif mode == 'v' then
    local prefix = input.args or ''
    local lines = vim.api.nvim_buf_get_lines(0, input.line1 - 1, input.line2, false)
    prompt = prefix .. ':\n' .. table.concat(lines, '\n')
  end

  local api_key = provider.load_credentials()
  if not api_key then
    return
  end

  local messages = {
    { role = 'user', content = prompt },
  }

  local request = provider.build_request(messages, {
    api_key = api_key,
    store = true,
  })

  local buffer = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  M.open_window(buffer, width, height)
  M.execute(request, buffer, provider)
end, {
  range = true,
  nargs = '?',
  complete = function() end,
})

vim.api.nvim_create_user_command('VibrProvider', function(input)
  if input.args == '' then
    vim.notify('Vibr: current provider is ' .. providers.current, vim.log.levels.INFO)
  else
    providers.set(input.args)
  end
end, {
  nargs = '?',
  complete = function()
    return providers.list()
  end,
})

return M
