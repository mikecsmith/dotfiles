-- LSP-related autocmds: folding upgrade

-- Upgrade to LSP folding when the server supports it
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("fathom_lsp_folding", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})
