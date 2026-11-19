return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      -- Plugins that expect nvim-web-devicons (lualine, bufferline) get icons from mini.icons
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
