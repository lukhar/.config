---@type VibrProvider
local M = {
  name = 'openai',
  defaults = {
    host = 'api.openai.com',
    port = 443,
    model = 'gpt-4.1',
  },
}

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

---@param messages VibrMessage[]
---@param options { host?: string, port?: integer, model?: string, store?: boolean, api_key: string }
---@return VibrRequest
function M.build_request(messages, options)
  local host = options.host or M.defaults.host
  local port = options.port or M.defaults.port
  local model = options.model or M.defaults.model

  local body = vim.fn.json_encode({
    model = model,
    messages = messages,
    stream = true,
    store = options.store or false,
  })

  local port_suffix = (port == 443) and '' or (':' .. port)

  return {
    url = 'https://' .. host .. port_suffix .. '/v1/chat/completions',
    method = 'POST',
    headers = {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = 'Bearer ' .. options.api_key,
    },
    body = body,
  }
end

---@param raw string
---@return string
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

return M
