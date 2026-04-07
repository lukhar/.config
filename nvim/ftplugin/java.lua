local function resolve_sdk()
  local ok, lines = pcall(vim.fn.readfile, '.sdkmanrc')

  if not ok then
    return {}
  end

  for _, line in ipairs(lines) do
    local sdk = line:match('^java=(.+)$')
    if sdk then
      local java_home = vim.env.HOME .. '/.sdkman/candidates/java/' .. sdk
      local version = java_home:match('(%d+)%.')
      if version then
        return {{ name = 'JavaSE-' .. version, path = java_home }}
      end
    end
  end

  return {}
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace = vim.env.HOME .. '/.cache/jdtls/workspace/' .. project_name

local config = {
  cmd = {
    vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls'),
    '-data',
    workspace,
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx20g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
  },
  root_dir = vim.fs.dirname((vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true }) or {})[1] or vim.fn.getcwd()),
  settings = {
    java = {
      configuration = {
        runtimes = resolve_sdk(),
      },
    },
  },
}

local ok, jdtls = pcall(require, 'jdtls')
if ok then
  jdtls.start_or_attach(config)
end
