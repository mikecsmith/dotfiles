-- bootstrap lazy.nvim, LazyVim and your plugins
local function broadcast_server_address()
  local address = vim.v.servername
  if not address then
    return
  end

  -- Kitty requires user vars to be base64 encoded
  -- (Requires Nvim 0.10+, or use a shell call for older versions)
  local encoded_addr = vim.base64.encode(address)

  -- OSC 1337 sequence to set user_var "nvim_server"
  io.stdout:write(string.format("\x1b]1337;SetUserVar=%s=%s\007", "nvim_server", encoded_addr))
end

-- Run immediately on startup
broadcast_server_address()

-- Optional: Re-broadcast on FocusGained in case you detach/attach sessions
vim.api.nvim_create_autocmd("FocusGained", {
  callback = broadcast_server_address,
})

require("config.lazy")
