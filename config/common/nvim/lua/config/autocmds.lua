-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("fathom_" .. name, { clear = true })
end

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

-- Disable prettier when DenoLS is active and no prettier config is found
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("deno"),
  callback = function(ev)
    local clients = vim.lsp.get_clients({ bufnr = ev.buf })
    local denols_attached = false
    for _, client in ipairs(clients) do
      if client.name == "denols" then
        denols_attached = true
        break
      end
    end
    vim.g.lazyvim_prettier_needs_config = denols_attached
  end,
})

-- Register starlark parser for tiltfile filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tiltfile",
  callback = function()
    vim.treesitter.language.register("starlark", "tiltfile")
  end,
})

-- Register stow prefix zsh filetypes
vim.filetype.add({
  filename = {
    ["dot-zshrc"] = "zsh",
    ["dot-zprofile"] = "zsh",
    ["dot-zshenv"] = "zsh",
  },
})
