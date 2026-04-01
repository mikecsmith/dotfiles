-- Remap metals keys from <leader>m to <leader>M to free up <leader>m for multicursor
return {
  {
    "scalameta/nvim-metals",
    keys = {
      { "<leader>me", false },
      { "<leader>mc", false },
      { "<leader>mh", false },
      {
        "<leader>Me",
        function() require("telescope").extensions.metals.commands() end,
        desc = "Metals commands",
      },
      {
        "<leader>Mc",
        function() require("metals").compile_cascade() end,
        desc = "Metals compile cascade",
      },
      {
        "<leader>Mh",
        function() require("metals").hover_worksheet() end,
        desc = "Metals hover worksheet",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>M", group = "metals" },
      },
    },
  },
}
