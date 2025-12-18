local opt = vim.opt

-- Set <Space> as leader key for custom mappings
vim.g.mapleader = " "

-- Line numbers + relative line numbers always enabled
opt.nu = true
opt.relativenumber = true

-- Tab settings:
opt.tabstop = 2 -- Tab width in spaces
opt.softtabstop = 2 -- Number of spaces when pressing Tab
opt.shiftwidth = 2 -- Number of spaces for indentation when using >> | <<
opt.expandtab = true -- Replace tabs with spaces

-- Smart indentation: enabled
opt.smartindent = true

-- Line wrap: disabled
opt.wrap = false

-- Disable swap file creation
opt.swapfile = false

-- Disable backups
opt.backup = false

-- Settings for persistent undo function:
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Directory for storing undo history
opt.undofile = true -- Enable saving undo history between sessions

-- Disable highlighting of all search results
opt.hlsearch = false

-- Enable incremental search (as you type)
opt.incsearch = true

-- Enable 24-bit color support in terminal
opt.termguicolors = true

-- Set minimum 8 lines of visibility above/below when scrolling
opt.scrolloff = 8

-- Enable sign column on the left of line numbers (for LSP, git, etc.)
opt.signcolumn = "yes"

-- Set update time in ms (affects responsiveness)
opt.updatetime = 50

-- Disable vertical line for text width limit
opt.colorcolumn = "0"
