return {
  "nvim-neotest/neotest",
  dependencies = {
    "marilari88/neotest-vitest",
    "markemmons/neotest-deno",
  },
  opts = {
    adapters = {
      ["neotest-vitest"] = {},
      ["neotest-deno"] = {},
    },
  },
}
