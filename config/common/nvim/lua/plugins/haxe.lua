-- Haxe language support (HaxeFlixel)
-- LSP: haxe-language-server (install via: install-haxe-lsp)
-- Treesitter: custom parser from github.com/vantreeseba/tree-sitter-haxe

vim.filetype.add({
  extension = {
    hx = "haxe",
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "haxe" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        once = true,
        callback = function()
          require("nvim-treesitter.parsers").haxe = {
            install_info = {
              url = "https://github.com/vantreeseba/tree-sitter-haxe",
              files = { "src/parser.c", "src/scanner.c" },
            },
          }
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        haxe_language_server = {
          cmd = { "node", vim.fn.expand("~/.local/share/haxe-language-server/bin/server.js") },
          filetypes = { "haxe" },
          root_markers = { "Project.xml", "project.xml", "*.hxml", ".git" },
          mason = false,
          before_init = function(params)
            local root = params.rootPath or vim.fn.getcwd()
            local has_project = vim.uv.fs_stat(root .. "/Project.xml")
              or vim.uv.fs_stat(root .. "/project.xml")
            if not has_project then return end
            local result = vim.fn.system("cd " .. vim.fn.shellescape(root) .. " && lime display html5 2>/dev/null")
            if vim.v.shell_error ~= 0 or result == "" then return end
            local hxml_path = root .. "/.haxelsp-display.hxml"
            local f = io.open(hxml_path, "w")
            if not f then return end
            f:write(result)
            f:close()
            params.initializationOptions = params.initializationOptions or {}
            params.initializationOptions.displayArguments = { hxml_path }
            vim.notify("[haxe-lsp] displayArguments=" .. vim.inspect(params.initializationOptions), vim.log.levels.INFO)
          end,
        },
      },
    },
  },
}
