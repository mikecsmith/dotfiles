-- Bootstrap lazy.nvim

-- Setup lazy.nvim
require("lazy").setup({
	defaults = {
		lazy = false, -- Do not lazy load by default
		version = false, -- Use the last commit automatically
	},

	spec = {
		-- import your plugins
		{ import = "plugins" },
    { import = "plugins.langs" }
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "onedark" } },
	-- automatically check for plugin updates
	checker = { enabled = true, notify = false },
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
