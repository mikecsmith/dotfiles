local util = require("lspconfig.util")

local get_root_dir = function(fname)
  return util.root_pattern(".git")(fname) or util.root_pattern("package.json", "tsconfig.json")(fname)
end

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
          root_dir = function(fname)
            return util.root_pattern("deno.json", "deno.jsonc")(fname)
          end,
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
        eslint = {
          root_dir = get_root_dir,
        },
        vtsls = {
          root_dir = get_root_dir,
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
}
