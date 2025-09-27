return {
  {
    "rcarriga/nvim-dap-ui",
    enabled = false,
  },
  {
    "igorlfs/nvim-dap-view",
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {},
    keys = {
      {
        "<leader>du",
        function()
          require("dap-view").toggle()
        end,
        desc = "Dap UI",
      },
    },
  },
}
