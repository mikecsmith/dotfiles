return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "helm" } },
  },
  {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    opts = {
      conceal_templates = {
        -- enable the replacement of templates with virtual text of their current values
        enabled = true, -- this might change to false in the future
      },
      indent_hints = {
        enabled = false,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        helm_ls = {
          settings = {
            ["helm-ls"] = {
              logLevel = "info",
              valuesFiles = {
                mainValuesFile = "values.yaml",
                lintOverlayValuesFile = "values.lint.yaml",
                additionalValuesFilesGlobPattern = "values*.yaml",
              },
              helmLint = {
                enabled = true,
                ignoredMessages = {},
              },
              yamlls = {
                enabled = true,
                enabledForFilesGlob = "*.{yaml,yml}",
                diagnosticsLimit = 50,
                showDiagnosticsDirectly = false,
                path = "yaml-language-server",
                initTimeoutSeconds = 3,
                config = {
                  schemas = {
                    kubernetes = "templates/**",
                  },
                  completion = true,
                  hover = true,
                  redhat = { telemetry = { enabled = false } },
                  capabilities = {
                    textDocument = {
                      foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      setup = {
        helm_ls = function()
          Snacks.util.lsp.on({ name = "helm-ls" }, function(_, client)
            client.server_capabilities.documentFormattingProvider = true
          end)
        end,
        yamlls = function()
          -- Prevent yamlls from attaching to Helm-related filetypes
          Snacks.util.lsp.on({ name = "yamlls" }, function(buffer)
            local ft = vim.bo[buffer].filetype
            if ft == "helm" or ft == "yaml.helm-values" then
              vim.schedule(function()
                vim.cmd("LspStop ++force yamlls")
              end)
            end
          end)
        end,
      },
    },
  },
}
