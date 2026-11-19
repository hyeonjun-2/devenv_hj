-- Autocommands. Loaded from init.lua right after options.

local group = vim.api.nvim_create_augroup("devenv", { clear = true })

-- Display tabs 4 columns wide, one tab per indent level.
-- Runs on BufWinEnter so it applies after .editorconfig (e.g. TF-A sets tab_width = 8).
-- Only the display width changes; files still contain real tab characters.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function()
    if not vim.bo.expandtab then
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 0 -- indent = one tab
      vim.bo.softtabstop = 0
    end
  end,
})

-- Reopening a file: jump to the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "gitcommit" or vim.b[ev.buf].devenv_last_loc then return end
    vim.b[ev.buf].devenv_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- File changed outside nvim (git checkout, another terminal): reload it when coming back
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Terminal resized: make split windows equal size again
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Live reload: watch every open file and reload it as soon as another program changes it
-- (Claude / Codex CLI in another tmux pane, git checkout, ...), like VSCode.
-- Buffers with unsaved changes are not overwritten: nvim asks what to do instead.
local watchers = {}

local function unwatch(buf)
  local w = watchers[buf]
  if w then
    w:stop()
    if not w:is_closing() then w:close() end
    watchers[buf] = nil
  end
end

local function watch(buf)
  unwatch(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then return end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" or not vim.uv.fs_stat(path) then return end
  local w = vim.uv.new_fs_event()
  if not w then return end
  watchers[buf] = w
  w:start(path, {}, vim.schedule_wrap(function(err, _, events)
    if err or not vim.api.nvim_buf_is_valid(buf) then return unwatch(buf) end
    if events.rename then
      -- File was replaced (write-to-temp + rename): wait for the new file, then re-watch it
      unwatch(buf)
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
          if vim.uv.fs_stat(path) then vim.cmd("checktime " .. buf) end
          watch(buf)
        end
      end, 100)
    else
      vim.cmd("checktime " .. buf)
    end
  end))
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
  group = group,
  callback = function(ev) watch(ev.buf) end,
})
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = group,
  callback = function(ev) unwatch(ev.buf) end,
})

-- Markdown: Space mp opens the file in a NEW Chrome window (rendered by the Markdown Viewer extension).
-- Turn on "Auto reload" in Markdown Viewer to refresh the page on every :w
local function open_in_chrome_window(path)
  if vim.fn.has("mac") == 1 then
    vim.system({ "open", "-na", "Google Chrome", "--args", "--new-window", path }, { detach = true })
    return
  end
  for _, exe in ipairs({ "google-chrome", "google-chrome-stable", "chromium", "chromium-browser" }) do
    if vim.fn.executable(exe) == 1 then
      vim.system({ exe, "--new-window", path }, { detach = true })
      return
    end
  end
  vim.ui.open(path) -- no Chrome: fall back to the default app
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("n", "<leader>mp", function()
      vim.cmd("silent! update") -- save first so the browser shows the latest text
      open_in_chrome_window(vim.api.nvim_buf_get_name(ev.buf))
    end, { buffer = ev.buf, desc = "Markdown Preview (new Chrome window)" })
  end,
})
