vim.api.nvim_set_hl(0, "VisualNonText", { fg = "#5D5F71", bg = "#24282d" })

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
          ███████  █████╗ █████████ ██║  ██║  ██████╗ ███╗   ███╗       ○   
          ██╔═══╝ ██╔══██╗╚══██╔══╝ ██║  ██║ ██╔═══██╗████╗ ████║     ○     
          █████╗  ███████║   ██║    ███████║ ██║   ██║██╔████╔██║   ○       
          ██╔══╝  ██╔══██║   ██║    ██╔══██║ ██║   ██║██║╚██╔╝██║ ○         
          ██║     ██║  ██║   ██║    ██║  ██║ ╚██████╔╝██║ ╚═╝ ██║           
          ╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═╝  ╚═╝  ╚═════╝ ╚═╝     ╚═╝           
]],
          sections = {
            { section = "header" },
            { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
            { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            { section = "startup" },
          },
        },
      },
      image = {},
    },
  },
  {
    "MunsMan/kitty-navigator.nvim",
    build = {
      "cp navigate_kitty.py ~/.config/kitty",
      "cp pass_keys.py ~/.config/kitty",
    },
    keys = {
      {
        "<M-h>",
        function()
          require("kitty-navigator").navigateLeft()
        end,
        desc = "Move left a Split",
        mode = { "n" },
      },
      {
        "<M-j>",
        function()
          require("kitty-navigator").navigateDown()
        end,
        desc = "Move down a Split",
        mode = { "n" },
      },
      {
        "<M-k>",
        function()
          require("kitty-navigator").navigateUp()
        end,
        desc = "Move up a Split",
        mode = { "n" },
      },
      {
        "<M-l>",
        function()
          require("kitty-navigator").navigateRight()
        end,
        desc = "Move right a Split",
        mode = { "n" },
      },
    },
  },
  {
    "pwntester/octo.nvim",
    opts = {
      picker = "snacks",
    },
  },
  {
    "mcauley-penney/visual-whitespace.nvim",
    config = true,
    event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
    opts = {},
  },
  {
    "Wansmer/treesj",
    keys = { { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" } },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  {
    "folke/ts-comments.nvim",
    opts = {
      langs = {
        dts = "// %s",
      },
    },
  },
}
