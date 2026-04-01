-- Editor behaviour autocmds: quit guard

-- Fixes super annoying issue with :q in last window when NeoTree/Copilot Chat are open
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("fathom_quit", { clear = true }),
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
