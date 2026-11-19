-- Install missing mason packages and wait for them (used by install.sh).
--   MASON_TOOLS="clangd bash-language-server" nvim --headless -c "luafile scripts/mason-install.lua"
-- Exits non-zero if any package fails. Uses the mason API directly, because
-- :MasonInstall treats harmless stderr output (e.g. npm warnings) as errors.

local function out(msg) io.stdout:write(msg .. "\n") end

local ok_reg, reg = pcall(require, "mason-registry")
if not ok_reg then
  out("  ✗ mason.nvim is not installed")
  vim.cmd("cquit 1")
end

reg.refresh()

local pending, failed = 0, {}
for name in (os.getenv("MASON_TOOLS") or ""):gmatch("%S+") do
  local ok, pkg = pcall(reg.get_package, name)
  if not ok then
    table.insert(failed, name .. " (not in mason registry)")
  elseif pkg:is_installed() then
    out("  ✓ " .. name .. " already installed")
  else
    out("  … installing " .. name)
    pending = pending + 1
    pkg:install({}, function(success, err)
      if success then
        out("  ✓ " .. name .. " installed")
      else
        table.insert(failed, name .. ": " .. tostring(err))
      end
      pending = pending - 1
    end)
  end
end

vim.wait(30 * 60 * 1000, function() return pending == 0 end, 500)

if pending > 0 then table.insert(failed, "timed out waiting for installs") end
if #failed > 0 then
  for _, f in ipairs(failed) do out("  ✗ " .. f) end
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
