return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      sections = {
        -- file name, then where the cursor is: function / struct (from aerial), e.g. "foo.c ⟩ main"
        lualine_c = { "filename", { "aerial", sep = " ⟩ " } },
      },
    },
  },
}
