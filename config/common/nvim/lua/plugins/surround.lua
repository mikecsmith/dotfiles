-- nvim-surround custom keymap usage (with 'gs' prefix):
--
-- The three "core" operations of add, delete, and change can be performed with:
--   - Add:    gsa{motion}{char}
--   - Delete: gsd{char}
--   - Change: gsc{target}{replacement}
--
-- For the following examples, * denotes the cursor position:
--
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             gsa iw )        (surround_words)
--     surr*ound_words             gsa iw (        ( surround_words )
--     *make strings               gsa $ "         "make strings"
--     [delete ar*ound me!]        gsd ]           delete around me!
--     remove <b>HTML t*ags</b>    gsd t           remove HTML tags
--     'change quot*es'            gsc ' "         "change quotes"
--     <b>or tag* types</b>        gsc t h1<CR>    <h1>or tag types</h1>
--     delete(functi*on calls)     gsd f           function calls
--
-- Note: Surrounding with an opening delimiter (e.g. '(') will add a space before/after the selection,
-- while using a closing delimiter (e.g. ')') will not include spaces.
-- For more information and advanced usage, see :h nvim-surround.usage
return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_insert_mappings = true
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    config = function()
      require("nvim-surround").setup({})

      local map = vim.keymap.set

      map("n", "gsa", "<Plug>(nvim-surround-normal)", { desc = "Add surround (motion)" })
      map("n", "gsaa", "<Plug>(nvim-surround-normal-cur)", { desc = "Add surround (line)" })
      map("n", "gsA", "<Plug>(nvim-surround-normal-line)", { desc = "Add surround (motion, new line)" })
      map("n", "gsAA", "<Plug>(nvim-surround-normal-cur-line)", { desc = "Add surround (line, new line)" })
      map("n", "gsd", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
      map("n", "gsc", "<Plug>(nvim-surround-change)", { desc = "Change surround" })
      map("n", "gsC", "<Plug>(nvim-surround-change-line)", { desc = "Change surround (new line)" })

      map("x", "gsv", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
      map("x", "gsV", "<Plug>(nvim-surround-visual-line)", { desc = "Surround selection (new line)" })

      map("i", "gsi", "<Plug>(nvim-surround-insert)", { desc = "Insert surround" })
      map("i", "gsI", "<Plug>(nvim-surround-insert-line)", { desc = "Insert surround (new line)" })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        ["gs"] = {
          name = "+surround",
        },
      },
    },
  },
}
