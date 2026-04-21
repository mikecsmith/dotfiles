vim.api.nvim_set_hl(0, "VisualNonText", { fg = "#5D5F71", bg = "#24282d" })

return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { replace_netrw = false },
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
  {
    "messages-float",
    virtual = true,
    keys = {
      {
        "<leader>N",
        function()
          local messages = vim.api.nvim_exec2("messages", { output = true }).output
          local lines = vim.split(messages, "\n")

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].bufhidden = "wipe"

          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.6)
          local row = math.floor((vim.o.lines - height) / 2)
          local col = math.floor((vim.o.columns - width) / 2)

          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            row = row,
            col = col,
            width = width,
            height = height,
            style = "minimal",
            title = " Messages ",
            title_pos = "center",
          })

          vim.api.nvim_win_set_cursor(win, { #lines, 0 })

          local close = function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
          end
          vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
          vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
        end,
        desc = "Messages",
      },
    },
  },
}
