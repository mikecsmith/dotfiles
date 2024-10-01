-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("fathom_" .. name, { clear = true })
end

-- Toggle cmp ghost text based on insert and cusor movement
vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
  group = augroup("cmp_toggle_ghost_text"),
  callback = require("fathom.cmp").toggle_ghost_text,
})

-- Fixes super annoying issue with :q in last window when NeoTree/Copilot Chat are open
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("quit"),
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") > 1 then
      return
    end

    if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "copilot-chat" then
      vim.cmd("quit")
    end
  end,
})

-- Quarto Autocmd - use this rather than after/ftplugin as LazyVim often overwrites
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quarto"),
  pattern = "quarto",
  callback = function()
    -- Activate otter for all languages, with all features using a Quarto specific treesitter query
    local tsquery = [[
      (fenced_code_block
      (info_string
        (language) @_lang
      ) @info
        (#match? @info "{")
      (code_fence_content) @content (#offset! @content)
      )
      ((html_block) @html @combined)

      ((minus_metadata) @yaml (#offset! @yaml 1 0 -1 0))
      ((plus_metadata) @toml (#offset! @toml 1 0 -1 0))
    ]]
    require("otter").activate(nil, true, true, tsquery)

    -- Overwrite the LazyVim keybindings to make <leader>cf work like <leader>cF
    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
      if vim.bo.filetype == "quarto" then
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      else
        LazyVim.format({ force = true })
      end
    end, { desc = "Format", buffer = true })

    -- Fixes the godawful autoindent on <CR> in lists
    vim.cmd("setlocal formatoptions-=ro")
  end,
})

-- Structurizr Autocmd - use this rather than after/ftplugin as LazyVim often overwrites
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("structurizr"),
  pattern = "structurizr",
  callback = function()
    local original_cwd = vim.fn.getcwd()
    local lsp_cwd = os.getenv("HOME") .. "/.local/share/lsp-servers/c4-dsl-language-server"

    vim.cmd("cd " .. lsp_cwd)

    vim.lsp.start({
      name = "c4-language-server",
      filetypes = { "structurizr" },
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      flags = {
        debounce_text_changes = 150,
        allow_incremental_sync = true,
        exit_timeout = 150,
      },
      cmd = { lsp_cwd .. "/bin/c4-language-server" },
      root_dir = vim.fs.root(0, { "workspace.dsl" }),
    })

    vim.cmd("cd " .. original_cwd)
    vim.cmd("setlocal nosmartindent")
  end,
})
