return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@class snacks.picker.Config
  opts = {
    -- Disable snacks indent because conflict with indent-blankline.lua
    indent = { enabled = false },
    -- Disable explorer for mini.files instead
    explorer = { enabled = false },
    picker = {
      sources = {
        explorer = {},
      },
    },
  },
}
