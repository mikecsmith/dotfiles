return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/fathom",
    name = "jsoncrack",
    ft = { "json", "yaml", "yml" },
    keys = {
      {
        "<leader>jc",
        function()
          require("fathom.jsoncrack").open_in_jsoncrack()
        end,
        desc = "Open in JSONCrack",
      },
    },
  },
}
