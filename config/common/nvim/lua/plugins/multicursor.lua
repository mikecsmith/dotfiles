-- Multicursor editing (Helix/VS Code style). All mappings under <leader>m.
--
-- WORKFLOW: Place cursors -> edit normally -> <Esc> to collapse back to one.
--
-- Placing cursors:
--   <leader>mn    Add cursor at next match of word/selection   (VS Code: Ctrl+D)
--   <leader>mN    Add cursor at prev match
--   <leader>ms    Skip next match (don't add cursor, advance)
--   <leader>mA    Select ALL matches in file                   (VS Code: Ctrl+Shift+L)
--   <leader>mj/k  Add cursor on line below/above               (VS Code: Ctrl+Alt+Down/Up)
--   <leader>ml    Add cursors via operator, e.g. <leader>mlip  (each line in paragraph)
--   Ctrl+click    Add/remove cursor with mouse
--
-- While multicursors are active (keymap layer):
--   n / N            Add next/prev match     (keep pressing to accumulate)
--   q / Q            Skip next/prev match    (advance without adding cursor)
--   <Left>/<Right>   Cycle which cursor is "main"
--   <leader>mx       Delete the main cursor
--   <leader>mt       Toggle cursors (move main solo, re-toggle to restore)
--   <leader>mr       Restore cursors if accidentally cleared
--   <Esc>            Re-enable disabled cursors, or clear all
--
-- Actions across cursors:
--   <leader>ma    Align cursor columns
--   <leader>mx    Transpose selections forward  (visual)
--   <leader>mM    Match within selection by regex (visual)
--   <leader>mS    Split selection by regex        (visual)
--   I / A         Insert/append per line           (visual)
--
-- Once cursors are placed, all normal vim editing (c, d, i, ., etc.) works
-- simultaneously at every cursor.

local function mc(fn, ...)
  local args = { ... }
  return function()
    require("multicursor-nvim")[fn](unpack(args))
  end
end

return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
      -- Add cursor above/below
      { "<leader>mk", mc("lineAddCursor", -1), desc = "Add cursor above", mode = { "n", "x" } },
      { "<leader>mj", mc("lineAddCursor", 1), desc = "Add cursor below", mode = { "n", "x" } },
      { "<leader>mK", mc("lineSkipCursor", -1), desc = "Skip cursor above", mode = { "n", "x" } },
      { "<leader>mJ", mc("lineSkipCursor", 1), desc = "Skip cursor below", mode = { "n", "x" } },

      -- Match word/selection (like Ctrl+D / Ctrl+Shift+L in VS Code)
      { "<leader>mn", mc("matchAddCursor", 1), desc = "Add next match", mode = { "n", "x" } },
      { "<leader>ms", mc("matchSkipCursor", 1), desc = "Skip next match", mode = { "n", "x" } },
      { "<leader>mN", mc("matchAddCursor", -1), desc = "Add prev match", mode = { "n", "x" } },
      { "<leader>mS", mc("matchSkipCursor", -1), desc = "Skip prev match", mode = { "n", "x" } },
      { "<leader>mA", mc("matchAllAddCursors"), desc = "Select all matches", mode = { "n", "x" } },

      -- Add cursor on each line of visual selection / motion
      { "<leader>ml", mc("addCursorOperator"), desc = "Add cursors (operator)", mode = { "n", "x" } },

      -- Align cursor columns
      { "<leader>ma", mc("alignCursors"), desc = "Align cursors", mode = { "n", "x" } },

      -- Restore cursors if accidentally cleared
      { "<leader>mr", mc("restoreCursors"), desc = "Restore cursors", mode = { "n", "x" } },

      -- Toggle (disable/enable) cursors
      { "<leader>mt", mc("toggleCursor"), desc = "Toggle cursor", mode = { "n", "x" } },

      -- Mouse support
      { "<c-leftmouse>", mc("handleMouse"), desc = "Add cursor (mouse)" },
      { "<c-leftdrag>", mc("handleMouseDrag"), desc = "Drag cursor (mouse)" },
      { "<c-leftrelease>", mc("handleMouseRelease"), desc = "Release cursor (mouse)" },

      -- Visual mode actions
      { "<leader>mS", mc("splitCursors"), desc = "Split by regex", mode = "x" },
      { "<leader>mM", mc("matchCursors"), desc = "Match by regex", mode = "x" },

      -- Transpose
      { "<leader>mx", mc("transposeCursors", 1), desc = "Transpose forward", mode = "x" },
      { "<leader>mX", mc("transposeCursors", -1), desc = "Transpose backward", mode = "x" },

      -- Visual insert/append
      { "I", mc("insertVisual"), mode = "x" },
      { "A", mc("appendVisual"), mode = "x" },
    },
    config = function()
      local mcn = require("multicursor-nvim")
      mcn.setup()

      -- Keymap layer: only active when multiple cursors exist
      mcn.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<left>", mcn.prevCursor)
        layerSet({ "n", "x" }, "<right>", mcn.nextCursor)
        layerSet({ "n", "x" }, "<leader>mx", mcn.deleteCursor)

        -- n/N to keep adding/skipping matches once in multicursor mode
        layerSet({ "n", "x" }, "n", function() mcn.matchAddCursor(1) end)
        layerSet({ "n", "x" }, "N", function() mcn.matchAddCursor(-1) end)
        layerSet({ "n", "x" }, "q", function() mcn.matchSkipCursor(1) end)
        layerSet({ "n", "x" }, "Q", function() mcn.matchSkipCursor(-1) end)

        layerSet("n", "<esc>", function()
          if not mcn.cursorsEnabled() then
            mcn.enableCursors()
          else
            mcn.clearCursors()
          end
        end)
      end)

      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>m", group = "multicursor" },
      },
    },
  },
}
