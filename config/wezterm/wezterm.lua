-- Pull in the wezterm API
local wezterm = require("wezterm")
local session_manager = require("session-manager")
local act = wezterm.action
local mux = wezterm.mux

-- --------------------------------------------------------------------
-- FUNCTIONS AND EVENT BINDINGS
-- --------------------------------------------------------------------

-- Session Manager event bindings
-- See https://github.com/danielcopper/wezterm-session-manager
wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

-- Wezterm <-> nvim pane navigation
-- You will need to install https://github.com/aca/wezterm.nvim
-- and ensure you export NVIM_LISTEN_ADDRESS per the README in that repo

local editor_prefix = "nvim"

local move_around = function(window, pane, direction_wez, direction_nvim)
	if pane:get_title():sub(1, string.len(editor_prefix)) == editor_prefix then
		window:perform_action(wezterm.action({ SendString = "\x1b" .. direction_nvim }), pane)
	else
		window:perform_action(wezterm.action({ ActivatePaneDirection = direction_wez }), pane)
	end
end

wezterm.on("move-left", function(window, pane)
	move_around(window, pane, "Left", "h")
end)

wezterm.on("move-right", function(window, pane)
	move_around(window, pane, "Right", "l")
end)

wezterm.on("move-up", function(window, pane)
	move_around(window, pane, "Up", "k")
end)

wezterm.on("move-down", function(window, pane)
	move_around(window, pane, "Down", "j")
end)

-- --------------------------------------------------------------------
-- CONFIGURATION
-- --------------------------------------------------------------------

local config = wezterm.config_builder()

-- Reload
config.automatically_reload_config = true

-- Muxing
config.unix_domains = {
	{
		name = "unix",
	},
}

-- Colors
config.color_scheme = "Nord (Gogh)"

-- Fonts
config.font_size = 13
config.font = wezterm.font({ family = "MesloLGS NF" })
config.bold_brightens_ansi_colors = true
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false

--Keyboard
config.send_composed_key_when_left_alt_is_pressed = false -- Allows for ALT keys to work in terminal but prevents typing £ with ALT+3
config.send_composed_key_when_right_alt_is_pressed = true -- Alows typing £ with right ALT+3
config.use_ime = false
config.use_dead_keys = false

-- Window
config.scrollback_lines = 5000
config.window_decorations = "RESIZE" -- Removes window title bar but allows resizing
config.enable_scroll_bar = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.colors = {
	tab_bar = {
		active_tab = {
			fg_color = "#073642",
			bg_color = "#2aa198",
		},
	},
}

-- Panes
-- wezterm.on("gui-startup", function()
-- 	local _, pane, _ = mux.spawn_window({})
-- 	pane:split({
-- 		direction = "Top",
-- 		size = 0.85,
-- 	})
-- end)

-- Mouse
config.mouse_bindings = {
	-- Open URLs with Ctrl+Click
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

-- Custom key bindings
config.disable_default_key_bindings = true

-- Define leader key
config.leader = { key = "phys:Space", mods = "ALT", timeout_milliseconds = 2000 }

-- Default key bindings
config.keys = {
	-- ----------------------------------------------------------------
	-- WINDOWS
	-- ----------------------------------------------------------------

	-- Font size
	{ key = "0", mods = "SUPER", action = act.ResetFontSize },
	{ key = "-", mods = "SUPER", action = act.DecreaseFontSize },
	{ key = "=", mods = "SUPER", action = act.IncreaseFontSize },

	-- Copy/Paste
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
	{
		key = "u",
		mods = "SUPER",
		action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
	},
	{ key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
	{ key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode }, -- Enter copy mode
	{ key = "x", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
	{ key = "x", mods = "SHIFT|SUPER", action = act.ActivateCopyMode },
	{ key = "X", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
	{ key = "X", mods = "SHIFT|SUPER", action = act.ActivateCopyMode },

	-- Command palette
	{ key = "p", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "p", mods = "SHIFT|SUPER", action = act.ActivateCommandPalette },
	{ key = "P", mods = "SHIFT|CTRL", action = act.ActivateCommandPalette },
	{ key = "P", mods = "SHIFT|SUPER", action = act.ActivateCommandPalette },
	{ key = "phys:Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },

	-- General Commands
	{ key = "f", mods = "SUPER", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "h", mods = "SUPER", action = act.HideApplication },
	{ key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackOnly") },
	{ key = "l", mods = "SUPER", action = act.ShowDebugOverlay },
	{ key = "m", mods = "SUPER", action = act.Hide },
	{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	{ key = "q", mods = "SUPER", action = act.QuitApplication },
	{ key = "r", mods = "SUPER", action = act.ReloadConfiguration },

	-- ----------------------------------------------------------------
	-- TABS
	-- ----------------------------------------------------------------

	{ key = "1", mods = "SUPER", action = act.ActivateTab(0) },
	{ key = "2", mods = "SUPER", action = act.ActivateTab(1) },
	{ key = "3", mods = "SUPER", action = act.ActivateTab(2) },
	{ key = "4", mods = "SUPER", action = act.ActivateTab(3) },
	{ key = "5", mods = "SUPER", action = act.ActivateTab(4) },
	{ key = "6", mods = "SUPER", action = act.ActivateTab(5) },
	{ key = "7", mods = "SUPER", action = act.ActivateTab(6) },
	{ key = "8", mods = "SUPER", action = act.ActivateTab(7) },
	{ key = "9", mods = "SUPER", action = act.ActivateTab(-1) }, -- Move to previous tab
	{ key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(1) }, -- Move to next tab
	{ key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(-1) }, -- Move to previous tab
	{ key = "PageDown", mods = "SHIFT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "PageUp", mods = "SHIFT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) }, -- Move to next tab
	{ key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) }, -- Move to previous tab
	{ key = "[", mods = "SUPER", action = act.ActivateTabRelative(-1) }, --Move to previous tab
	{ key = "]", mods = "SUPER", action = act.ActivateTabRelative(1) }, -- Move to next tab
	{ key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) }, -- Close current tab
	{ key = "o", mods = "LEADER", action = act.ShowTabNavigator }, -- Show tab navigator

	-- Rename current tab
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- ----------------------------------------------------------------
	-- PANES
	-- ----------------------------------------------------------------

	-- Vertical split
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = act.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},

	-- Horizontal split
	{
		key = "-",
		mods = "LEADER",
		action = act.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},

	-- Move panes without vim
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },

	-- Resize panes
	{ key = "LeftArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
	{ key = "UpArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "DownArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },

	-- CTRL + (h,j,k,l) to move between panes
	{ key = "h", mods = "ALT", action = act({ EmitEvent = "move-left" }) },
	{ key = "j", mods = "ALT", action = act({ EmitEvent = "move-down" }) },
	{ key = "k", mods = "ALT", action = act({ EmitEvent = "move-up" }) },
	{ key = "l", mods = "ALT", action = act({ EmitEvent = "move-right" }) },

	-- Adjust pane size with ALT + (h,j,k,l)
	{ key = "h", mods = "CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
	{ key = "j", mods = "CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
	{ key = "k", mods = "CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
	{ key = "l", mods = "CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },

	-- Close/kill active pane
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

	-- Swap active pane with another one
	{ key = "s", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },

	-- Zoom current pane (toggle)
	{ key = "z", mods = "SUPER", action = act.TogglePaneZoomState },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "f", mods = "ALT", action = act.TogglePaneZoomState },

	-- Move to next/previous pane
	{ key = "[", mods = "LEADER", action = act.ActivatePaneDirection("Prev") },
	{ key = "]", mods = "LEADER", action = act.ActivatePaneDirection("Next") },

	-- ----------------------------------------------------------------
	-- Workspaces
	-- ----------------------------------------------------------------

	-- Attach to muxer
	{ key = "a", mods = "LEADER", action = act.AttachDomain("unix") },

	-- Detach from muxer
	{ key = "d", mods = "LEADER", action = act.DetachDomain({ DomainName = "unix" }) },

	-- Show list of workspaces
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },

	-- Rename current session
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},

	-- Session manager bindings
	{ key = "s", mods = "SUPER|ALT", action = act({ EmitEvent = "save_session" }) },
	{ key = "l", mods = "SUPER|ALT", action = act({ EmitEvent = "load_session" }) },
	{ key = "r", mods = "SUPER|ALT", action = act({ EmitEvent = "restore_session" }) },
}

-- and finally, return the configuration to wezterm
return config
