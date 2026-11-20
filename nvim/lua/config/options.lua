-- Editor options. Loaded first from init.lua (before plugins), so the leader key is set in time.

-- Leader key: Space. Must be set before plugins load (their <leader> keys use it).
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Search: ignore case, unless the pattern contains an uppercase letter
vim.o.ignorecase = true
vim.o.smartcase = true

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

-- Folding by syntax (treesitter): functions, if/switch blocks, structs. za toggles, zR/zM open/close all.
-- foldlevel 99 = files open fully unfolded. Languages without a treesitter parser simply don't fold.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 99
