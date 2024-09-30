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

-- Activate otter for all languages, with all features using a Quarto specific treesitter query
require("otter").activate(nil, true, true, tsquery)

-- Overwrite the LazyVim keybindings to make <leader>cf work like <leader>cF
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  -- Conditional check for the filetype - use require conform for quarto files
  if vim.bo.filetype == "quarto" then
    require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
  else
    LazyVim.format({ force = true })
  end
end, { desc = "Format" })
