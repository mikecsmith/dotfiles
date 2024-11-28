return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "deno",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = {
                  enabled = "literals",
                },
                variableTypes = {
                  enabled = true,
                },
                enumMemberValues = {
                  enabled = true,
                },
              },
            },
            deno = {
              codeLens = {
                implementations = true,
                references = true,
                test = true,
              },
            },
          },
        },
      },
    },
  },
  { "markemmons/neotest-deno" },
  {
    "nvim-neotest/neotest",
    opts = { adapters = { "neotest-deno" } },
  },
}
