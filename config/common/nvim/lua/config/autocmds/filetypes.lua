-- Filetype-specific autocmds: quarto, tiltfile, deno, otter

-- Quarto - use this rather than after/ftplugin as LazyVim often overwrites
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("fathom_quarto", { clear = true }),
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
  group = vim.api.nvim_create_augroup("fathom_deno", { clear = true }),
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

-- Activate otter for markdown files with yaml-language-server schema frontmatter
local function activate_ihj_otter()
  if vim.bo.filetype ~= "markdown" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
  if #lines < 2 then
    return
  end

  local is_frontmatter = lines[1]:match("^%-%-%-%s*$")
  local has_schema = lines[2]:match("^#%s*yaml%-language%-server:%s*$schema=")

  if is_frontmatter and has_schema then
    local ok, otter = pcall(require, "otter")
    if ok then
      otter.activate({ "yaml" })
    else
      vim.notify("otter.nvim not found - unable to parse yaml frontmatter", vim.log.levels.WARN)
    end
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  pattern = "*.md",
  callback = activate_ihj_otter,
})
