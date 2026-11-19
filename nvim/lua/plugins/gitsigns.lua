return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      attach_to_untracked = true, -- new files not yet in git: show every line as added
    },
    keys = {
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Next Hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev Hunk" },
      { "<leader>ghp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
      { "<leader>ghr", function() require("gitsigns").reset_hunk() end, desc = "Reset Hunk" },
      { "<leader>ghs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
      { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
      { "<leader>ghd", function() require("gitsigns").diffthis() end, desc = "Diff This" },
      {
        "<leader>ghi",
        function()
          -- Inline diff in the code (like VSCode): colored changed lines, deleted lines shown, changed words
          local gs = require("gitsigns")
          vim.g.gitsigns_inline_diff = not vim.g.gitsigns_inline_diff
          local on = vim.g.gitsigns_inline_diff
          gs.toggle_linehl(on)
          gs.toggle_deleted(on)
          gs.toggle_word_diff(on)
          vim.notify("Inline diff " .. (on and "ON" or "OFF"))
        end,
        desc = "Toggle Inline Diff",
      },
    },
  },
}
