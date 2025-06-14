return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    'mason-org/mason.nvim',
    'neovim/nvim-lspconfig',
  },

  config = function()
    require('mason-lspconfig').setup({
      automatic_installation = true,
    })
  end

}
