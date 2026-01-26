local M = {}

---@class VibrProvider
---@field name string
---@field defaults { host: string, port: integer, model: string }
---@field build_request fun(messages: VibrMessage[], options: table): VibrRequest
---@field parse_chunk fun(raw: string): string
---@field load_credentials? fun(): string|nil

---@type table<string, VibrProvider>
M.providers = {}

---@type string
M.current = 'openai'

---@param provider VibrProvider
function M.register(provider)
  M.providers[provider.name] = provider
end

---@param name? string
---@return VibrProvider|nil
function M.get(name)
  return M.providers[name or M.current]
end

---@param name string
function M.set(name)
  if M.providers[name] then
    M.current = name
    vim.notify('Vibr: switched to ' .. name, vim.log.levels.INFO)
  else
    vim.notify('Vibr: unknown provider ' .. name, vim.log.levels.ERROR)
  end
end

---@return string[]
function M.list()
  local names = {}
  for name, _ in pairs(M.providers) do
    table.insert(names, name)
  end
  return names
end

-- Load and register providers
M.register(require('custom.plugins.vibr.providers.openai'))
M.register(require('custom.plugins.vibr.providers.ollama'))

return M
