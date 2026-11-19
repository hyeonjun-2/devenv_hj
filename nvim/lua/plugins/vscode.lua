return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false, -- load at startup so the colorscheme applies before other UI
    priority = 1000,
    opts = { transparent = true }, -- keep terminal background
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },
}
