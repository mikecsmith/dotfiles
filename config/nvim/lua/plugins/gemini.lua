return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>ag",
      function()
        require("snacks.terminal").toggle("gemini", {
          cwd = vim.fn.getcwd(),
          win = {
            position = "right",
            on_buf = function(self)
              local buf = self.buf or vim.api.nvim_get_current_buf()
              vim.keymap.set("t", "<M-h>", function()
                require("kitty-navigator").navigateLeft()
              end, { buffer = buf, silent = true })
              vim.keymap.set("t", "<M-j>", function()
                require("kitty-navigator").navigateDown()
              end, { buffer = buf, silent = true })
              vim.keymap.set("t", "<M-k>", function()
                require("kitty-navigator").navigateUp()
              end, { buffer = buf, silent = true })
              vim.keymap.set("t", "<M-l>", function()
                require("kitty-navigator").navigateRight()
              end, { buffer = buf, silent = true })
            end,
          },
        })
      end,
      desc = "Toggle Gemini Terminal (docked right)",
    },
  },
}
