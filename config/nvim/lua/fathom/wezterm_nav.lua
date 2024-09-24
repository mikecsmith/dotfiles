---@class fathom.wezterm_nav
local M = {}
-- Function to check if a Wezterm pane exists and activate it if present
function M.check_wezterm_pane(direction)
	-- Map directions to Wezterm CLI direction names
	local wezterm_directions = {
		h = "left",
		j = "down",
		k = "up",
		l = "right",
	}

	-- Run the Wezterm CLI command to get the pane ID in the desired direction
	local pane_id = vim.fn.system("wezterm cli get-pane-direction " .. wezterm_directions[direction])

	-- Trim whitespace from pane_id (system() includes a newline at the end)
	pane_id = vim.trim(pane_id)

	-- If a pane ID is found, activate the pane
	if pane_id and pane_id ~= "" then
		local wezterm_command = "wezterm cli activate-pane --pane-id " .. pane_id
		os.execute(wezterm_command)
	end
end

-- Function to check if movement is possible in Neovim and fallback to Wezterm
function M.move_or_fallback(direction)
	-- Check if a Neovim split exists in the desired direction
	local target_window = vim.fn.winnr(direction)

	-- If there is no Neovim window in the desired direction, fallback to Wezterm
	if vim.fn.winnr() == target_window then
		M.check_wezterm_pane(direction)
	else
		-- Move within Neovim splits
		vim.cmd("wincmd " .. direction)
	end
end

return M
