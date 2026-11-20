return {
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      -- only the snacks features listed here are enabled
      picker = {},
      indent = {}, -- indent guides
      scroll = {}, -- smooth scrolling
      explorer = {}, -- file tree sidebar
      bigfile = { notify = false }, -- huge files (logs, dumps): turn off heavy features so they open fast (silently)
    },
    keys = {
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep Word Under Cursor" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jump History (Ctrl-o list)" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      { "<leader>wm", function() Snacks.zen.zoom() end, desc = "Toggle Zoom Window" },
      {
        "<leader>sd",
        function() Snacks.picker.diagnostics({ severity = { min = vim.diagnostic.severity.ERROR } }) end,
        desc = "Diagnostics (errors)",
      },
    },
  },
}
