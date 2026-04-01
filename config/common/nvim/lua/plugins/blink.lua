return {
  {
    "saghen/blink.cmp",
    dependencies = { "fang2hou/blink-copilot" },
    build = "cargo build --release",
    opts = {
      sources = {
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 10,
            async = true,
          },
        },
      },
      keymap = {
        preset = "none", -- Disable default presets to control the flow fully

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        -- VS Code: Enter only accepts if you've actively selected an item
        ["<CR>"] = { "select_and_accept", "fallback" },

        -- VS Code: In a snippet, Tab jumps to next placeholder. Otherwise accepts completion.
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        -- Standard navigation
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        -- Scroll docs
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      completion = {
        -- VS Code: Auto-insert brackets after function completions
        accept = {
          auto_brackets = { enabled = true },
        },

        -- VS Code: Keep completions available inside snippet placeholders
        trigger = {
          prefetch_on_insert = true,
          show_in_snippet = true,
        },

        -- VS Code: "Ghost text" allows you to see the completion before accepting
        ghost_text = { enabled = true },

        -- VS Code: The top item is always selected.
        -- This is critical for "Tab to accept" to work instantly.
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },

        menu = {
          scrollbar = true,
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label" },
            },
          },
        },

        -- VS Code: Documentation appears automatically
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
      },

      signature = { enabled = true },

      -- Cmdline: compact layout with fixed-width label
      cmdline = {
        completion = {
          menu = {
            min_width = 25,
            draw = {
              columns = {
                { "kind_icon" },
                { "label" },
              },
              components = {
                label = {
                  width = { min = 10, max = 30, fill = true },
                },
              },
            },
          },
        },
      },
    },
  },
}
