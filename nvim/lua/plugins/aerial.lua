return {
  {
    "stevearc/aerial.nvim", -- outline: functions / structs / macros of the current file
    -- load with files (not only on Space cs) so the statusline can show the current function
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Symbols Outline (aerial)" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" }, -- clangd first, treesitter as fallback
      attach_mode = "global", -- the outline follows whichever window you are in
      layout = { default_direction = "prefer_right", min_width = 30 },
      show_guides = true,
    },
  },
}
