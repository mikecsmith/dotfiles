local util = require("lspconfig.util")

local get_root_dir = function(fname)
  return util.root_pattern(".git")(fname) or util.root_pattern("package.json", "tsconfig.json")(fname)
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      denols = {
        filetypes = { "typescript", "typescriptreact" },
        root_dir = function(fname)
          return util.root_pattern("deno.jsonc", "deno.json")(fname)
        end,
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
}
