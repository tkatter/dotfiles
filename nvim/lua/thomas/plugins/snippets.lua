return {
  {
    "echasnovski/mini.snippets",
    opts = function(_, opts)
      local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")

      opts.snippets = {
        snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
      }
    end,
  },
}
