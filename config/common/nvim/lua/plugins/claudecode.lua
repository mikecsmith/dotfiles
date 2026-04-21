-- Claude Code in an adjacent Kitty pane instead of an embedded snacks terminal.
-- Requires: kitty with allow_remote_control + listen_on, a `claude` binary on PATH.

-- Unique Kitty window title per nvim session. Random suffix so multiple
-- nvim instances in the same Kitty app each own a distinct Claude pane.
-- Title is our only match key — orphans from prior nvim sessions are
-- intentionally left alone for manual cleanup + --resume.
local function random_suffix()
  local t = {}
  for i = 1, 5 do
    t[i] = string.char(math.random(97, 122))
  end
  return table.concat(t)
end
local CLAUDE_TITLE = "claude-" .. random_suffix()

local function claude_match()
  return "title:" .. CLAUDE_TITLE
end

local function in_kitty()
  return (vim.env.KITTY_WINDOW_ID or vim.env.KITTY_LISTEN_ON) ~= nil
end

local function kitten(subcmd, args)
  local cmd = { "kitten", "@" }
  local listen = vim.env.KITTY_LISTEN_ON
  if listen and listen ~= "" then
    table.insert(cmd, "--to")
    table.insert(cmd, listen)
  end
  table.insert(cmd, subcmd)
  for _, a in ipairs(args or {}) do
    table.insert(cmd, a)
  end
  local result = vim.system(cmd, { text = true }):wait()
  return result.stdout or "", result.code
end

local function window_exists()
  local out, rc = kitten("ls", { "--match", claude_match() })
  if rc ~= 0 then return false end
  return vim.trim(out) ~= "[]"
end

local function current_layout()
  local wid = vim.env.KITTY_WINDOW_ID
  if not wid then return nil end
  local out, rc = kitten("ls", { "--match", "id:" .. wid })
  if rc ~= 0 then return nil end
  local ok, data = pcall(vim.json.decode, out)
  if not ok or type(data) ~= "table" or not data[1] then return nil end
  local my_id = tonumber(wid)
  for _, tab in ipairs(data[1].tabs or {}) do
    for _, win in ipairs(tab.windows or {}) do
      if win.id == my_id then return tab.layout end
    end
  end
  return nil
end

-- Last args passed to open(), so ensure_visible() (argless API) can relaunch
-- if the pane was manually closed between sends.
local cached_open_args = nil

local kitty_provider
kitty_provider = {
  setup = function(_) end,

  open = function(cmd_string, env_table, config, focus)
    cached_open_args = { cmd_string, env_table, config }
    if focus == nil then focus = true end
    if window_exists() then
      if focus then
        kitten("focus-window", { "--match", claude_match() })
      end
      return
    end
    local args = {
      "--type=window",
      "--location=vsplit",
      "--cwd=" .. vim.fn.getcwd(),
      "--title=" .. CLAUDE_TITLE,
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
      kitten("close-window", { "--match", claude_match() })
    end
  end,

  simple_toggle = function(cmd_string, env_table, config)
    if window_exists() then
      kitten("action", { "toggle_layout", "stack" })
    else
      kitty_provider.open(cmd_string, env_table, config, true)
    end
  end,

  focus_toggle = function(cmd_string, env_table, config)
    if not window_exists() then
      kitty_provider.open(cmd_string, env_table, config, true)
    else
      kitten("focus-window", { "--match", claude_match() })
    end
  end,

  -- Called by the plugin on send when focus_after_send=false: ensure the
  -- Claude pane is on screen without stealing focus from nvim.
  ensure_visible = function()
    if window_exists() then
      if current_layout() == "stack" then
        kitten("action", { "toggle_layout", "stack" })
      end
      return
    end
    if cached_open_args then
      kitty_provider.open(cached_open_args[1], cached_open_args[2], cached_open_args[3], false)
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
