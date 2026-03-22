return {
  {
    "mrjones2014/codesettings.nvim",
    lazy = false,
    opts = {
      live_reload = true,
      merge_list = "prepend",
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          before_init = function(_, config)
            require("codesettings").with_local_settings("jsonls", config)
          end,
        },
      },
    },
  },
}
