return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-project.nvim" },
      { "BurntSushi/ripgrep" },
    },
    keys = function()
      local builtin = require("telescope.builtin")
      return {
        { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        {
          "<leader><space>",
          function()
            builtin.find_files({
              hidden = true,
              no_ignore = true,
              cwd = Fathom.root({ buf = 0 }),
            })
          end,
          desc = "Find Files (Root Dir)",
        },
        {
          "<leader>/",
          function()
            builtin.live_grep({
              hidden = true,
              no_ignore = true,
              cwd = Fathom.root({ buf = 0 }),
            })
          end,
          desc = "Find Files (Root Dir)",
        },
        {
          "<leader>ff",
          "<cmd>Telescope find_files hidden=true no_ignore=true<cr>",
          desc = "Find All Files",
        },
        { "<leader>fF", "<cmd>Telescope find_files hidden=true no_ignore=false<cr>", desc = "Find All Files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Find Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
        { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Projects" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
        { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      }
    end,
    opts = function()
      local telescope = require("telescope")
      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("project")

      return {
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = " ",
          file_ignore_patterns = { "node_modules", ".git", "dist", "_site" },
          layout_config = {
            horizontal = { width = 0.9, height = 0.85 },
          },
          path_display = { "truncate" },
        },
        pickers = {
          find_files = {
            theme = "ivy",
          },
          live_grep = {
            theme = "ivy",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          project = {
            hidden_files = true,
          },
        },
      }
    end,
  },
}
