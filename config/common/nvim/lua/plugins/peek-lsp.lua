-- Peek definition / type definition in a centered floating window.
-- Opens the actual source buffer (fully scrollable) in a float.
-- gp = peek definition, gt = peek type definition
-- Inside the float: q/<Esc> to close, <CR> to jump to the definition.

local function peek(method, jump_fn)
  return function()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, method, params, function(err, result)
      if err or not result or vim.tbl_isempty(result) then
        vim.notify("No result found", vim.log.levels.INFO)
        return
      end

      local target = vim.islist(result) and result[1] or result
      local uri = target.uri or target.targetUri
      local range = target.range or target.targetSelectionRange

      local bufnr = vim.uri_to_bufnr(uri)
      vim.fn.bufload(bufnr)

      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.6)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local win = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        title = " " .. vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.") .. " ",
        title_pos = "center",
      })

      vim.api.nvim_win_set_cursor(win, { range.start.line + 1, range.start.character })
      vim.cmd("normal! zz")

      vim.wo[win].winfixbuf = true
      vim.wo[win].number = true
      vim.wo[win].relativenumber = true
      vim.wo[win].cursorline = true
      vim.wo[win].signcolumn = "number"

      local close = function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end
      vim.keymap.set("n", "q", close, { buffer = bufnr, nowait = true })
      vim.keymap.set("n", "<Esc>", close, { buffer = bufnr, nowait = true })
      vim.keymap.set("n", "<CR>", function()
        close()
        jump_fn()
      end, { buffer = bufnr, nowait = true })
    end)
  end
end

return {
  {
    "peek-lsp",
    virtual = true,
    event = "LspAttach",
    keys = {
      { "gp", peek("textDocument/definition", vim.lsp.buf.definition), desc = "Peek definition" },
      { "gt", peek("textDocument/typeDefinition", vim.lsp.buf.type_definition), desc = "Peek type definition" },
    },
  },
}
