return {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
        require('copilot').setup {
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = '<C-l>',
                    next = '<C-j>',
                    prev = '<C-k>',
                    dismiss = '<esc>',
                },
            },
            filetypes = {
                yaml = true,
                markdown = true,
                javascript = true,
                typescript = true,
                rust = true,
                css = true,
                html = true,
                json = true,
                lua = true,
            },
            workspace_folders = {
                '/home/thomas/Code/Local',
                '/home/thomas/Code/Projects',
            },
        }
    end,
}
