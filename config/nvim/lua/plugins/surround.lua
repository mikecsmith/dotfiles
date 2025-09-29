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
    opts = {
      keymaps = {
        insert = "gsi",
        insert_line = "gsI",
        normal = "gsa",
        normal_cur = "gsaa",
        normal_line = "gsA",
        normal_cur_line = "gsAA",
        visual = "gsv",
        visual_line = "gsV",
        delete = "gsd",
        change = "gsc",
        change_line = "gsC",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        ["gs"] = {
          name = "+surround",
          a = { "Add surround (motion)" },
          A = { "Add surround (motion, new line)" },
          aa = { "Add surround to current line" },
          AA = { "Add surround to current line, new line" },
          d = { "Delete surround" },
          c = { "Change surround" },
          C = { "Change surround, new line" },
          v = { "Surround visual selection" },
          V = { "Surround visual line selection" },
          i = { "Insert surround (insert mode)" },
          I = { "Insert surround, new line (insert mode)" },
        },
      },
    },
  },
}
