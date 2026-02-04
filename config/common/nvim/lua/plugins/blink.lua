return {
  {
    "saghen/blink.cmp",
    dependencies = { "fang2hou/blink-copilot" },
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
            score_offset = 100,
            async = true,
          },
        },
      },
      keymap = {
        preset = "none", -- Disable default presets to control the flow fully

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        -- VS Code: Accept with Enter
        ["<CR>"] = { "accept", "fallback" },

        -- VS Code: Tab accepts if menu open, otherwise jumps snippet, otherwise indents
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
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

        -- VS Code: Documentation appears automatically
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },

      -- VS Code: Signature help (parameter hints) pop up automatically
      signature = { enabled = true },
    },
  },
}
