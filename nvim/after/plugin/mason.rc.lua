local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

mason.setup()

lspconfig.setup {
  ensure_installed = {
    'rust_analyzer',
    'tsserver',
    'lua_ls',
    'volar',
    'tailwindcss',
    'html',
    'cssls',
    'emmet_ls',
    'solargraph'
  },
}
