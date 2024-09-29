local M = {}

--- Applies a git patch from a URL
--- @param plugin_name string
--- @param patch_url string
--- @param patch_name string
function M.apply_patch(plugin_name, patch_url, patch_name)
  local plugin_dir = vim.fn.stdpath("data") .. "/lazy/" .. plugin_name
  local patch_path = plugin_dir .. "/" .. patch_name .. ".patch"

  vim.fn.system({ "git", "-C", plugin_dir, "reset", "--hard", "HEAD" })
  vim.fn.system({ "git", "-C", plugin_dir, "clean", "-fd" })
  vim.fn.system({ "curl", "-L", patch_url, "-o", patch_path })

  local result = vim.fn.system({ "git", "-C", plugin_dir, "apply", patch_path })

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to apply patch: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Patch applied successfully to " .. plugin_name, vim.log.levels.INFO)
  end
end

return M
