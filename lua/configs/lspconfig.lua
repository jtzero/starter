-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"


-- EXAMPLE
local servers = { "html", "cssls" }
if vim.bo.filetype == "astro" then
  table.insert(servers, "astro")
end
if vim.bo.filetype == "terraform" then
  table.insert(servers, "terraformls")
end
if EditorConfig.lsp_servers ~= nil then
  concatTables(servers, EditorConfig.lsp_servers)
end
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- configuring single server, example: typescript
-- lspconfig.tsserver.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
--
