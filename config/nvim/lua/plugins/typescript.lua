return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "deno",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = {
                  enabled = "literals",
                },
                variableTypes = {
                  enabled = true,
                },
                enumMemberValues = {
                  enabled = true,
                },
              },
            },
            deno = {
              codeLens = {
                implementations = true,
                references = true,
                test = true,
              },
            },
          },
        },
        vtsls = {
          settings = {
            typescript = {
              compilerOptions = {
                customConditions = "typescript",
                moduleResolution = "nodenext",
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")

      local function resolve_amaro_loader()
        local root = vim.fn.getcwd()
        local pattern = root .. "/node_modules/.pnpm/amaro@*/node_modules/amaro/dist/register-strip.mjs"
        local matches = vim.fn.glob(pattern, true, true)
        if #matches > 0 then
          return matches[1]
        end
        return nil
      end

      local loader = resolve_amaro_loader()

      local vitest_config = {
        type = "node",
        request = "launch",
        name = "Debug Vitest (strip-types)",
        runtimeExecutable = "node",
        runtimeArgs = vim.list_extend({
          "--experimental-strip-types",
          "--conditions=typescript",
        }, loader and { "--import", loader } or {}),
        program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
        args = { "run", "${file}" },
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      }

      for _, ft in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        table.insert(dap.configurations[ft], vitest_config)
      end
    end,
  },
}
