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
