return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "starlark" },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "tilt",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tilt_ls = {},
      },
    },
  },
}
