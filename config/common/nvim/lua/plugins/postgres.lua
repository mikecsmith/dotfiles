return {
  { "mason-org/mason.nvim", opts = {
    ensure_installed = { "postgrestools" },
  } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        postgres_lsp = {},
      },
    },
  },
}
