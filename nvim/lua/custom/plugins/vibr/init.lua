local M = {}

---@class VibrMessage
---@field role "user"|"assistant"|"system"
---@field content string

---@class VibrRequest
---@field url string
---@field method string
---@field headers table<string, string>
---@field body string

---@param options { backend: string, host: string, port: integer, model: string, role: string, stream: boolean, store: boolean, api_key?: string }
---@param content string
---@return VibrRequest
function M.build_request(options, content)
  local body = vim.fn.json_encode({
    model = options.model,
    messages = {
      { role = options.role, content = content },
    },
    stream = options.stream,
    store = options.store,
  })

  local is_openai = options.backend == 'openai'
  local protocol = is_openai and 'https' or 'http'

  local headers = {
    ['Content-Type'] = 'application/json',
  }

  if is_openai and options.api_key then
    headers['Authorization'] = 'Bearer ' .. options.api_key
  end

  return {
    url = protocol .. '://' .. options.host .. ':' .. options.port .. '/v1/chat/completions',
    method = 'POST',
    headers = headers,
    body = body,
  }
end

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

function M.load_credentials()
  local path = vim.fn.expand('~') .. '/.config/nvim/.credentials.secret'
  local ok, content = pcall(vim.fn.readfile, path)
  if not ok then
    vim.notify('Vibr: credentials file not found', vim.log.levels.ERROR)
    return nil
  end

  local ok2, creds = pcall(vim.fn.json_decode, content)
  if not ok2 or not creds or not creds.openai then
    vim.notify('Vibr: invalid credentials format', vim.log.levels.ERROR)
    return nil
  end

  return creds.openai.key
end

function M.parse_chunk(raw)
  local json_string = raw:match('^data:%s*(.*)') or raw

  local success, json = pcall(vim.fn.json_decode, json_string)

  if not success then
    return ''
  end

  if not json or not json.choices or not json.choices[1] then
    return ''
  end

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

---@param request VibrRequest
---@param buffer integer
---@param on_complete function
function M.execute_query(request, buffer, on_complete)
  local cmd = M.to_curl(request)
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify('API Error: ' .. (result.stderr or 'Unknown error'), vim.log.levels.ERROR)
        return
      end

      if not result.stdout or result.stdout == '' then
        vim.notify('No response from API', vim.log.levels.WARN)
        return
      end

      local content = M.parse_chunk(result.stdout)

      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content, '\n'))
      vim.api.nvim_set_option_value('filetype', 'markdown', {buf = buffer})

      on_complete()
    end)
  end)
end

---@param request VibrRequest
---@param buffer integer
function M.execute_stream_query(request, buffer)
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
          local content = M.parse_chunk(chunk)
          if content and content ~= '' then
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

vim.api.nvim_create_user_command('Vibr', function(input)
  local mode = (input.range == 0 and 'n') or 'v'
  local stream = not input.bang
  local prompt

  if mode == 'n' then
    prompt = input.args
  elseif mode == 'v' then
    local prefix = input.args or ''
    local lines = vim.api.nvim_buf_get_lines(0, input.line1 - 1, input.line2, false)
    prompt = prefix .. ':\n' .. table.concat(lines, '\n')
  end

  local api_key = M.load_credentials()
  if not api_key then
    return
  end

  local request = M.build_request({
    api_key = api_key,
    host = 'api.openai.com',
    port = 443,
    model = 'gpt-4.1',
    role = 'user',
    store = true,
    backend = 'openai',
    stream = stream,
  }, prompt)

  local buffer = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  if stream then
    M.open_window(buffer, width, height)
    M.execute_stream_query(request, buffer)
  else
    M.execute_query(request, buffer, function()
      M.open_window(buffer, width, height)
    end)
  end
end, {
  bang = true,
  range = true,
  nargs = '?',
  complete = function() end,
})

return M
