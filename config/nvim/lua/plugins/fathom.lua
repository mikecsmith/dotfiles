return {
  { "folke/noice.nvim", enabled = false },
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
}
