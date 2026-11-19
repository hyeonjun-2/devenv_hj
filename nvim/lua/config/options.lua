-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes" -- always show the sign column (gitsigns marks) so text doesn't shift

-- Show tabs and trailing spaces (to tell tabs from spaces)
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·"

-- New split windows open to the right / below (nvim default is left / above)
vim.o.splitright = true
vim.o.splitbelow = true

-- One statusline at the bottom, even with split windows
vim.o.laststatus = 3
