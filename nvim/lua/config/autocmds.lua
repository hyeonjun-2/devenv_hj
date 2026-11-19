-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Display tabs 4 columns wide, one tab per indent level.
-- Runs on BufWinEnter so it applies after .editorconfig (e.g. TF-A sets tab_width = 8).
-- Only the display width changes; files still contain real tab characters.
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    if not vim.bo.expandtab then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 0 -- indent = one tab
      vim.bo.softtabstop = 0
    end
  end,
})
