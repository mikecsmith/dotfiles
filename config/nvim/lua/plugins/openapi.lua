return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "spectral-language-server",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        spectral = {},
      },
    },
  },
}
