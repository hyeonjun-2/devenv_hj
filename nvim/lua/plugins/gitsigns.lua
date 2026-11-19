return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Next Hunk" },
      { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev Hunk" },
      { "<leader>ghp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
      { "<leader>ghr", function() require("gitsigns").reset_hunk() end, desc = "Reset Hunk" },
      { "<leader>ghs", function() require("gitsigns").stage_hunk() end, desc = "Stage Hunk" },
      { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
      { "<leader>ghd", function() require("gitsigns").diffthis() end, desc = "Diff This" },
    },
  },
}
