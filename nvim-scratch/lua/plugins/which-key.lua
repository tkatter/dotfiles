return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
        triggers = {
            { '<leader>', mode = { 'n', 'v' } },
        },
        spec = {
            { 'gs', group = 'surround' },
            { '<leader>b', group = 'buffer' },
            { '<leader>t', group = 'tab' },
            { '<leader>f', group = 'file' },
            { '<leader>w', group = 'window' },
            { 'g', group = 'edit' },
            { 'z', group = 'folds' },
            { '[', group = 'previous' },
            { ']', group = 'next' },
        },
    },
    keys = {
        {
            '<leader>?',
            function()
                require('which-key').show { global = false }
            end,
            desc = 'Buffer Local Keymaps (which-key)',
        },
    },
}
