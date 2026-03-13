return {
  {
    "mrjones2014/codesettings.nvim",
    lazy = false,
    opts = {
      hot_reload = true,
    },
    config = function(_, opts)
      local codesettings = require("codesettings")
      codesettings.setup(opts)

      local function fix_relative_uris(tbl, root)
        if type(tbl) ~= "table" then
          return
        end
        for k, v in pairs(tbl) do
          if k == "url" and type(v) == "string" and v:match("^%./") then
            local absolute = vim.fs.normalize(root .. "/" .. v:gsub("^%./", ""))
            tbl[k] = vim.uri_from_fname(absolute)
          elseif type(v) == "table" then
            fix_relative_uris(v, root)
          end
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if not client or client.name ~= "jsonls" then
            return
          end

          local base_config = { settings = client.settings or {} }
          local merged = codesettings.with_local_settings(client.name, base_config, opts)

          if not merged or not merged.settings then
            return
          end

          local root = client.root_dir or vim.uv.cwd()

          fix_relative_uris(merged.settings, root)

          client.settings = merged.settings
          client:notify("workspace/didChangeConfiguration", {
            settings = client.settings,
          })
        end,
      })
    end,
  },
}
