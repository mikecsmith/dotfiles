local original_cwd = vim.fn.getcwd()
local lsp_cwd = os.getenv("HOME") .. "/.local/share/lsp-servers/c4-dsl-language-server"

vim.cmd("cd " .. lsp_cwd)

vim.lsp.start({
  name = "c4-language-server",
  filetypes = { "structurizr" },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
    exit_timeout = 150,
  },
  cmd = { lsp_cwd .. "/bin/c4-language-server" },
  root_dir = vim.fs.root(0, { "workspace.dsl" }),
})

vim.cmd("cd " .. original_cwd)
