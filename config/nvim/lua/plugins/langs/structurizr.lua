return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = function()
      vim.api.nvim_create_augroup("LspAutoCommands", { clear = true })

      --- Structurizr
      vim.api.nvim_create_autocmd("FileType", {
        group = "LspAutoCommands",
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
              allow_incremental_sync = true 
            },
            cmd = { lsp_cwd .. "/bin/c4-language-server" },
            root_dir = vim.fs.root(0, { "workspace.dsl" }),
          })

          vim.cmd("cd " .. original_cwd)
        end,
      })
    end,
  },
}
