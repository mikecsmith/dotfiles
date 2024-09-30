-- LazyVim already has the injected formatter configured
return {
  -- Update Marksman to work with Quarto
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          filetypes = { "markdown", "markdown.mdx", "quarto" },
          root_dir = require("lspconfig.util").root_pattern(".git", ".marksman.toml", "_quarto.yml"),
        },
      },
    },
  },
  -- Otter adds LSP capabilities to Quarto code blocks
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
      },
    },
    opts = {
      verbose = {
        no_code_found = false,
      },
    },
  },
  -- Extend the LazyVim markdown renderer to also handle Quarto docs
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "quarto" },
    },
    ft = { "quarto" },
  },
}
