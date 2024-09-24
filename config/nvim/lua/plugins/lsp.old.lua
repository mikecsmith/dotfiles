if true then
  return {}
end
---@diagnostic disable: missing-fields
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { -- Configuration for working with Lua
        {
          "folke/lazydev.nvim",
          ft = "lua",
          opts = {
            library = {
              { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
          },
        },
        { "Bilal2453/luvit-meta", lazy = true },
        { -- Adds completion sources for Lua require statements
          "hrsh7th/nvim-cmp",
          opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
              name = "lazydev",
              group_index = 0, -- Setting this to 0 skips load LuaLS completions
            })
          end,
        },
      },
      { "folke/neoconf.nvim", opts = {} }, -- This allows for setting up LSPs via JSON files - leaving for reference
    },
    opts = function()
      --@class PluginLspOpts
      local ret = {
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
            -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
            -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
            -- prefix = "icons",
          },
          severity_sort = true,
          inlay_hints = {
            enabled = true,
            exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
          },
          document_highlight = {
            enabled = true,
          },
          -- add any global capabilities here
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
        },
      }
      return ret
    end,
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "marksman",
          "kotlin_language_server",
          "pyright",
        },
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "black",
          "goimports",
          "stylua",
          "shfmt",
          "isort",
          "tree-sitter-cli",
          "jupytext",
          "ktlint",
          "prettierd",
          "yamlfix",
        },
      })
      local wk = require("which-key")

      local function get_quarto_resource_path()
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
            table.insert(result, match)
          end
          return result
        end

        local f = assert(io.popen("quarto --paths", "r"))
        local s = assert(f:read("*a"))
        f:close()
        return strsplit(s, "\n")[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file("", true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once("quarto not found, lua library files not loaded")
      else
        table.insert(lua_library_files, resource_path .. "/lua-types")
        table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Provides a default LSP setup alongside the ability to configure specific LSP settings
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
          })
        end,
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  disable = { "trailing-space" },
                },
                workspace = {
                  checkThirdParty = false,
                },
                doc = {
                  privateName = { "^_" },
                },
                telemetry = {
                  enable = false,
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          })
        end,
        ["marksman"] = function()
          lspconfig.marksman.setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
            filetypes = { "markdown", "quarto" },
            root_dir = util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
          })
        end,
        ["ts_ls"] = function()
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
            filetypes = { "js", "javascript", "typescript", "ojs" },
          })
        end,
        ["jsonls"] = function()
          lspconfig.jsonls.setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
            settings = {
              json = {
                schemas = {
                  {
                    fileMatch = { "package.json" },
                    url = "https://json.schemastore.org/package.json",
                  },
                  {
                    fileMatch = { "tsconfig*.json" },
                    url = "https://json.schemastore.org/tsconfig.json",
                  },
                  {
                    fileMatch = {
                      ".prettierrc",
                      ".prettierrc.json",
                      "prettier.config.json",
                    },
                    url = "https://json.schemastore.org/prettierrc.json",
                  },
                  {
                    fileMatch = { ".eslintrc", ".eslintrc.json" },
                    url = "https://json.schemastore.org/eslintrc.json",
                  },
                  {
                    fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                    url = "https://json.schemastore.org/babelrc.json",
                  },
                  {
                    fileMatch = { "lerna.json" },
                    url = "https://json.schemastore.org/lerna.json",
                  },
                  {
                    fileMatch = { "now.json", "vercel.json" },
                    url = "https://json.schemastore.org/now.json",
                  },
                  {
                    fileMatch = {
                      ".stylelintrc",
                      ".stylelintrc.json",
                      "stylelint.config.json",
                    },
                    url = "http://json.schemastore.org/stylelintrc.json",
                  },
                },
              },
            },
          })
        end,
        ["yamlls"] = function()
          lspconfig.yamlls.setup({
            capabilities = capabilities,
            flags = lsp_flags,
            sign_text = true,
            settings = {
              yaml = {
                schemaStore = {
                  enable = true,
                  url = "https://www.schemastore.org/api/json/catalog.json",
                },
                schemas = {
                  ["http://json.schemastore.org/gitlab-ci.json"] = { ".gitlab-ci.yml" },
                  ["https://json.schemastore.org/bamboo-spec.json"] = {
                    "bamboo-specs/*.{yml,yaml}",
                  },
                  ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
                    "docker-compose*.{yml,yaml}",
                  },
                  ["http://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                  ["http://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
                  ["http://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
                  ["http://json.schemastore.org/stylelintrc.json"] = ".stylelintrc.{yml,yaml}",
                  ["http://json.schemastore.org/circleciconfig"] = ".circleci/**/*.{yml,yaml}",
                },
              },
            },
          })
        end,
      })

      -- Custom LSPs configured manually
      vim.api.nvim_create_augroup("LspAutoCommands", { clear = true })

      --- Structurizr
      vim.api.nvim_create_autocmd("FileType", {
        group = "LspAutoCommands",
        pattern = "structurizr",
        callback = function()
          -- C4 LSP defaults to logging in the `cwd` and Neovim starts the LSP in the `cwd` so dir hot potato is required to put the logs in an appropriate spot
          local original_cwd = vim.fn.getcwd()

          local lsp_cwd = os.getenv("HOME") .. "/.local/share/lsp-servers/c4-dsl-language-server"

          vim.cmd("cd " .. lsp_cwd)

          vim.lsp.start({
            name = "c4-language-server",
            filetypes = { "structurizr" },
            capabilities = capabilities,
            flags = lsp_flags,
            cmd = { lsp_cwd .. "/bin/c4-language-server" },
            root_dir = vim.fs.root(0, { "workspace.dsl" }),
          })

          vim.cmd("cd " .. original_cwd)
        end,
      })

      --- Tilt
      vim.api.nvim_create_autocmd("BufRead", {
        group = "LspAutoCommands",
        pattern = { "Tiltfile" },
        command = "setfiletype tiltfile",
      })

      lspconfig.tilt_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      -- Diagnostics keybindings
      wk.add({
        { "<leader>d", group = "Diagnostics" }, -- Group declaration
        { "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Open diagnostics float" },
        { "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Set location list" },
        { "<leader>d]", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next diagnostic" },
        { "<leader>d[", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Previous diagnostic" },
        { "<leader>dq", "<cmd>lua vim.diagnostic.setqflist()<cr>", desc = "Set quickfix list" },
      })

      -- LSP Keybindings that only work when an LSP is attached
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Check if Copilot is the only LSP attached to the buffer
          local active_clients = vim.lsp.get_clients({ bufnr = ev.buf })
          local other_lsps_attached = false

          for _, client in pairs(active_clients) do
            if client.name ~= "copilot" then
              other_lsps_attached = true
              break
            end
          end

          -- If no other LSPs are attached, do not set keymaps
          if not other_lsps_attached then
            return
          end

          -- Check if keymaps have already been set for this buffer
          if vim.b[ev.buf].lsp_keymaps_set then
            return
          end

          -- Set buffer-local keymaps using the 'buffer' option
          wk.add({
            {
              "<leader>.",
              "<cmd>lua vim.lsp.buf.code_action()<cr>",
              desc = "Perform code action",
              buffer = ev.buf,
            },
            {
              "gd",
              "<cmd>lua vim.lsp.buf.definition()<cr>",
              desc = "Go to definition",
              buffer = ev.buf,
            },
            {
              "gr",
              "<cmd>lua vim.lsp.buf.references()<cr>",
              desc = "Go to references",
              buffer = ev.buf,
            },
            {
              "K",
              "<cmd>lua vim.lsp.buf.hover()<cr>",
              desc = "Open hover window",
              buffer = ev.buf,
            },
            { "<leader>l", group = "LSP Commands" },
            {
              "<leader>lr",
              "<cmd>lua vim.lsp.buf.rename()<cr>",
              desc = "Rename symbol",
              buffer = ev.buf,
            },
            {
              "<leader>lf",
              "<cmd>lua vim.lsp.buf.format()<cr>",
              desc = "Format buffer",
              buffer = ev.buf,
            },
          })

          -- Mark that keymaps have been set for this buffer
          vim.b[ev.buf].lsp_keymaps_set = true
        end,
      })
    end,
  },
}
