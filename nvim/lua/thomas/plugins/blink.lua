return {
  "saghen/blink.cmp",
  dependencies = "echasnovski/mini.snippets",
  opts = {
    snippets = { preset = "mini_snippets" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
