-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("fathom_" .. name, { clear = true })
end

-- Toggle cmp ghost text based on insert and cusor movement
vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
  group = augroup("cmp_toggle_ghost_text"),
  callback = require("fathom.cmp").toggle_ghost_text,
})

-- Attach LSP to structurizr filetype
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("lsp_structurizr"),
  pattern = "structurizr",
  callback = function()
    -- C4 LSP defaults to logging in the `cwd` and Neovim starts the LSP in the `cwd` so dir hot potato is required to put the logs in an appropriate spot
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
      },
      cmd = { lsp_cwd .. "/bin/c4-language-server" },
      root_dir = vim.fs.root(0, { "workspace.dsl" }),
    })

    vim.cmd("cd " .. original_cwd)
  end,
})
