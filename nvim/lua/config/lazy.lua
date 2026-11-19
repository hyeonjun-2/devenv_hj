-- Bootstrap lazy.nvim (plugin manager): clone it on first run
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Every file in lua/plugins/ returns a list of plugin specs
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- plugins load at startup unless their spec says otherwise (event / cmd / keys)
    version = false, -- use the latest git commit (exact versions are pinned in lazy-lock.json)
  },
  install = { colorscheme = { "vscode", "habamax" } }, -- colorscheme to use while installing on first run
  checker = {
    enabled = true, -- check for plugin updates in the background
    notify = false, -- but don't pop up a message (see :Lazy)
  },
})
