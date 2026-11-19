return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag: downloads the prebuilt fuzzy matcher binary
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      -- "enter": Enter accepts, Ctrl-n/Ctrl-p or Up/Down to select, Ctrl-e to close (VSCode-like)
      keymap = {
        preset = "enter",
        -- Ctrl-Space is taken by ulauncher, so use Ctrl-l to open the menu / toggle docs
        ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
      },
      completion = {
        documentation = { auto_show = true }, -- show docs next to the menu
      },
      sources = {
        default = { "lsp", "path", "buffer", "snippets" },
      },
    },
  },
}
