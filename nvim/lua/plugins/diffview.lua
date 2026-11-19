return {
  {
    "sindrets/diffview.nvim", -- review all changed files at once (like VSCode's Source Control view)
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      {
        "<leader>gv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Diffview: Changed Files (toggle)",
      },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: Current File History" },
    },
    opts = {},
  },
}
