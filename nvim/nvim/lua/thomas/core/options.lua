-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.opt.reliativenumber = true

local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clipboard
opt.clipboard = "unnamedplus"

-- Cursor
-- opt.guicursor = "i:ver50-Cursor-blinkon500-blinkoff300-blinkwait10"
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-TermCursor"
opt.cursorline = true

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Wrap long lines at words
opt.linebreak = true

-- Indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Show whitespace.
opt.list = true
opt.listchars = { space = "⋅", trail = "⋅", tab = "  ↦" }

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Colors
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Split
opt.splitright = true
opt.splitbelow = true
opt.isfname:append("@-@")
opt.updatetime = 50

opt.mouse = "a"
vim.g.editorconfig = true

-- Mini Snippets in Completion
vim.g.lazyvim_mini_snippets_in_completion = true
