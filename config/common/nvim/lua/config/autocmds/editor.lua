-- Editor behaviour autocmds: quit guard

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("fathom_quit", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") > 1 then
      return
    end

    if vim.bo.filetype == "snacks_picker_list" then
      vim.cmd("quit")
    end
  end,
})
