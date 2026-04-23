-- Editor behaviour autocmds: quit guard
--
-- If the only remaining windows are sidebars, quit nvim rather than leaving
-- orphaned sidebar windows behind.
local sidebar_filetypes = {
  snacks_picker_list = true,
  snacks_explorer = true,
  snacks_layout_box = true,
  trouble = true,
  qf = true,
  help = true,
  ["neo-tree"] = true,
}

vim.api.nvim_create_autocmd("WinClosed", {
  group = vim.api.nvim_create_augroup("fathom_quit", { clear = true }),
  callback = function(args)
    local closing_win = tonumber(args.match)
    vim.schedule(function()
      local wins = vim.tbl_filter(function(w)
        if w == closing_win then
          return false
        end
        return vim.api.nvim_win_get_config(w).relative == ""
      end, vim.api.nvim_list_wins())

      if #wins == 0 then
        return
      end

      for _, w in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(w)
        if not sidebar_filetypes[vim.bo[buf].filetype] then
          return
        end
      end

      vim.cmd("qa")
    end)
  end,
})

-- When nvim is launched with a directory argument, cd into it and show the
-- snacks dashboard instead of netrw / the snacks explorer.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("dir_arg_dashboard", { clear = true }),
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end
    local arg = vim.fn.argv(0)
    if vim.fn.isdirectory(arg) == 0 then
      return
    end
    vim.cmd.cd(arg)
    local dir_buf = vim.api.nvim_get_current_buf()
    Snacks.dashboard()
    pcall(vim.api.nvim_buf_delete, dir_buf, { force = true })
  end,
})
