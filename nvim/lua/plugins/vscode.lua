return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false, -- load at startup so the colorscheme applies before other UI
    priority = 1000,
    opts = {
      transparent = true, -- keep terminal background
      -- Inline diff (gitsigns, Space ghi): the theme's default line colors are too bright
      -- to read text on, so use dark backgrounds like VSCode's diff editor.
      group_overrides = {
        GitSignsAddLn = { bg = "#2f3d26" },        -- added line
        GitSignsChangeLn = { bg = "#23384a" },     -- changed line
        GitSignsDeleteVirtLn = { bg = "#4b1818" }, -- deleted line (shown in place)
        GitSignsAddInline = { bg = "#4b6332" },    -- changed words inside a line
        GitSignsChangeInline = { bg = "#2f5578" },
        GitSignsDeleteInline = { bg = "#7a2020" },
        GitSignsDeleteVirtLnInLine = { bg = "#7a2020" },
      },
    },
    config = function(_, opts)
      require("vscode").setup(opts)
      vim.cmd.colorscheme("vscode")
    end,
  },
}
