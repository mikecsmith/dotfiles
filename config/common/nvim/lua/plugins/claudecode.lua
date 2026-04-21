-- Claude Code in an adjacent Kitty pane instead of an embedded snacks terminal.
-- Requires: kitty with allow_remote_control + listen_on, a `claude` binary on PATH.

local KITTY_MATCH_TITLE = "claude-code-nvim"

local function in_kitty()
  return (os.getenv("KITTY_WINDOW_ID") or os.getenv("KITTY_LISTEN_ON")) ~= nil
end

local function kitten(subcmd, args)
  local cmd = { "kitten", "@" }
  local listen = os.getenv("KITTY_LISTEN_ON")
  if listen and listen ~= "" then
    table.insert(cmd, "--to")
    table.insert(cmd, listen)
  end
  table.insert(cmd, subcmd)
  for _, a in ipairs(args or {}) do
    table.insert(cmd, a)
  end
  local out = vim.fn.system(cmd)
  return out, vim.v.shell_error
end

local function window_exists()
  local out, rc = kitten("ls", { "--match", "title:" .. KITTY_MATCH_TITLE })
  if rc ~= 0 then return false end
  return vim.trim(out) ~= "[]"
end

local kitty_provider
kitty_provider = {
  setup = function(_) end,

  open = function(cmd_string, env_table, config, focus)
    if focus == nil then focus = true end
    if window_exists() then
      if focus then
        kitten("focus-window", { "--match", "title:" .. KITTY_MATCH_TITLE })
      end
      return
    end
    local args = {
      "--type=window",
      "--location=vsplit",
      "--cwd=" .. vim.fn.getcwd(),
      "--title=" .. KITTY_MATCH_TITLE,
      "--bias=" .. math.floor((config.split_width_percentage or 0.38) * 100),
      -- Copy env from the calling nvim window. Without this, the new Kitty
      -- window inherits Kitty.app's launch env (no zshrc sourced) — PATH loses
      -- ~/.local/bin, LANG/LC_ALL may be C, Nerd Font glyphs render as tofu.
      "--copy-env",
    }
    if not focus then
      table.insert(args, "--keep-focus")
    end
    -- MCP env from claudecode.nvim overrides copied env per-key
    for k, v in pairs(env_table or {}) do
      table.insert(args, "--env")
      table.insert(args, k .. "=" .. tostring(v))
    end
    table.insert(args, "sh")
    table.insert(args, "-c")
    table.insert(args, cmd_string)
    kitten("launch", args)
  end,

  close = function()
    if window_exists() then
      kitten("close-window", { "--match", "title:" .. KITTY_MATCH_TITLE })
    end
  end,

  simple_toggle = function(cmd_string, env_table, config)
    if window_exists() then
      kitten("close-window", { "--match", "title:" .. KITTY_MATCH_TITLE })
    else
      kitty_provider.open(cmd_string, env_table, config, true)
    end
  end,

  focus_toggle = function(cmd_string, env_table, config)
    if not window_exists() then
      kitty_provider.open(cmd_string, env_table, config, true)
    else
      kitten("focus-window", { "--match", "title:" .. KITTY_MATCH_TITLE })
    end
  end,

  get_active_bufnr = function() return nil end,

  is_available = function()
    return in_kitty() and vim.fn.executable("kitten") == 1
  end,
}

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSend",
    "ClaudeCodeAdd",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeSelectModel",
  },
  opts = {
    terminal_cmd = vim.fn.expand("~/.local/bin/claude"),
    terminal = {
      split_side = "right",
      split_width_percentage = 0.38,
      provider = in_kitty() and kitty_provider or "snacks",
      auto_close = true,
    },
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = false,
      keep_terminal_focus = false,
    },
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "snacks_picker_list" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
