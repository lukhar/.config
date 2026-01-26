---@type VibrProvider
local M = {
  name = 'ollama',
  defaults = {
    host = 'localhost',
    port = 11434,
    model = 'llama3.2',
  },
}

function M.load_credentials()
  -- Ollama doesn't require authentication
  return ''
end

---@param messages VibrMessage[]
---@param options { host?: string, port?: integer, model?: string, api_key: string }
---@return VibrRequest
function M.build_request(messages, options)
  local host = options.host or M.defaults.host
  local port = options.port or M.defaults.port
  local model = options.model or M.defaults.model

  local body = vim.fn.json_encode({
    model = model,
    messages = messages,
    stream = true,
  })

  return {
    url = 'http://' .. host .. ':' .. port .. '/api/chat',
    method = 'POST',
    headers = {
      ['Content-Type'] = 'application/json',
    },
    body = body,
  }
end

---@param raw string
---@return string
function M.parse_chunk(raw)
  local success, json = pcall(vim.fn.json_decode, raw)

  if not success then
    return ''
  end

  if not json or not json.message then
    return ''
  end

  return json.message.content or ''
end

return M
