return {
  -- Disable LazyVim's built in Copilot CMP support.
  { "zbirenbaum/copilot-cmp", enabled = false },
  -- Tweak Copilot setup to make it more like VS Code
  {
    "zbirenbaum/copilot.lua",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- Use alt to interact with Copilot.
        keymap = {
          -- Disable the built-in mapping, we'll configure it in nvim-cmp.
          accept = false,
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      filetypes = { markdown = true },
    },
    config = function(_, opts)
      local cmp = require("cmp")
      local copilot = require("copilot.suggestion")

      require("copilot").setup(opts)

      local function set_trigger(trigger)
        vim.b.copilot_suggestion_auto_trigger = trigger
        vim.b.copilot_suggestion_hidden = not trigger
      end

      -- Hide suggestions when the completion menu is open.
      cmp.event:on("menu_opened", function()
        if copilot.is_visible() then
          copilot.dismiss()
        end
        set_trigger(false)
      end)

      -- Hide suggestions if a vim snippet is active
      cmp.event:on("menu_closed", function()
        set_trigger(not vim.snippet.active({ direction = 1 }))
      end)
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      {
        "garymjr/nvim-snippets",
        opts = {
          extended_filetypes = {
            structurizr = { "structurizr" },
          },
        },
      },
    },
    build = require("fathom.build").apply_patch(
      "nvim-cmp",
      "https://github.com/hrsh7th/nvim-cmp/pull/1955.patch",
      "1955"
    ),
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local copilot = require("copilot.suggestion")

      opts.sources = require("fathom.cmp").process_sources(opts.sources)

      opts.matching = {
        disallow_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = false,
        disallow_symbol_nonprefix_matching = false,
      }

      opts.mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if copilot.is_visible() then
            copilot.accept()
          elseif cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          else
            return fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping({
          i = function(fallback)
            if vim.snippet.active({ direction = -1 }) then
              vim.schedule(function()
                vim.snippet.jump(-1)
              end)
              return
            end
            return fallback()
          end,
        }),
        ["<CR>"] = cmp.mapping({
          i = LazyVim.cmp.confirm({ cmp.ConfirmBehavior.Replace, select = false }),

          s = cmp.confirm({ select = true }),
        }),
        ["<C-CR>"] = cmp.mapping(function(fallback)
          cmp.abort()
          fallback()
        end),
        ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
        ["<Down>"] = cmp.mapping.select_next_item(), -- Down arrow to cycle down
        ["<C-j>"] = cmp.mapping.select_next_item(), -- Ctrl + j to cycle down
        ["<Up>"] = cmp.mapping.select_prev_item(), -- Up arrow to cycle up
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- Ctrl + k to cycle up
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
      })
      opts.preselect = cmp.PreselectMode.None

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = cmp.mapping({
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          }),
          ["<CR>"] = cmp.mapping({
            c = cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          }),
        }),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<Tab>"] = {
            c = function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end,
          },
          ["<CR>"] = cmp.mapping({
            c = cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
          }),
        }),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        ---@diagnostic disable-next-line: missing-fields
        matching = { disallow_symbol_nonprefix_matching = false },
      })
      return opts
    end,
  },
}
