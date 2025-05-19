return {
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      -- Dynamically add schemas from every subfolder of $XDG_DATA_HOME/schemas containing .json files
      local schemas = {
        {
          name = "Kubernetes 1.33.0",
          uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.33.0-standalone-strict/all.json",
        },
      }

      local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
      local schemas_dir = data_home .. "/schemas"
      local uv = vim.loop

      local function scan_json_recursive(dir, prefix)
        local handle = uv.fs_scandir(dir)
        if not handle then
          return
        end
        while true do
          local name, typ = uv.fs_scandir_next(handle)
          if not name then
            break
          end
          local full_path = dir .. "/" .. name
          local display_name = prefix and (prefix .. "/" .. name) or name
          if typ == "directory" then
            scan_json_recursive(full_path, display_name)
          elseif typ == "file" and name:match("%.json$") then
            table.insert(schemas, {
              name = "Schema: " .. display_name,
              uri = full_path,
            })
          end
        end
      end

      scan_json_recursive(schemas_dir)

      local cfg = require("yaml-companion").setup({
        schemas = schemas,
      })
      require("lspconfig")["yamlls"].setup(cfg)
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections.lualine_z = {
        {
          function()
            local schema = require("yaml-companion").get_buf_schema(0)
            if schema.result[1].name == "none" then
              return ""
            end
            return schema.result[1].name
          end,
        },
        opts.sections.lualine_z,
      }
    end,
  },
}
