return {
    'mason-org/mason.nvim',
    -- cmd: "Mason",
    build = ':MasonUpdate',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    config = function()
        require('mason').setup {
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                },
                check_outdated_packages_on_open = true,
            },
        }
    end,
}
