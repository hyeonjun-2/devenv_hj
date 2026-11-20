return {
  {
    "neovim/nvim-lspconfig", -- default configs (cmd, filetypes, root markers) for language servers
    lazy = false,
    config = function()
      -- clangd: only override cmd to add flags.
      -- --query-driver = compilers clangd may run to find their system headers:
      -- ~/toolchains (any target: aarch64, arm-none-eabi, riscv, ...), /opt, apt gcc, buildroot host toolchains
      local toolchains = vim.fn.expand("~/toolchains")
      local drivers = table.concat({
        toolchains .. "/**/bin/*-gcc", toolchains .. "/**/bin/*-g++",
        "/opt/**/bin/*-gcc", "/opt/**/bin/*-g++",
        "/usr/bin/*-gcc*", "/usr/bin/*-g++*",
        "**/host/bin/*-gcc", "**/host/bin/*-g++",
      }, ",")
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--query-driver=" .. drivers },
      })

      -- Drop warnings/info/hints from language servers entirely, keep errors only.
      -- (Some UIs, like the snacks explorer, show every diagnostic and can't filter by severity.)
      local publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx)
        if result and result.diagnostics then
          result.diagnostics = vim.tbl_filter(function(d)
            return d.severity == nil or d.severity == vim.diagnostic.severity.ERROR
          end, result.diagnostics)
        end
        return publish(err, result, ctx)
      end

      -- Diagnostics: show errors only (hide warnings/hints), with the message at the end of the line
      local errors_only = { min = vim.diagnostic.severity.ERROR }
      vim.diagnostic.config({
        virtual_text = { severity = errors_only },
        signs = { severity = errors_only },
        underline = { severity = errors_only },
        jump = { severity = errors_only }, -- ]d / [d skip warnings too
      })

      -- Space ud: turn error display on/off (all buffers). Same key as LazyVim.
      vim.keymap.set("n", "<leader>ud", function()
        local on = not vim.diagnostic.is_enabled()
        vim.diagnostic.enable(on)
        vim.notify("Diagnostics " .. (on and "ON" or "OFF"))
      end, { desc = "Toggle Diagnostics (errors)" })

      -- Keymaps set only in buffers where a language server is attached
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc }) end
          map("gD", vim.lsp.buf.declaration, "Go to Declaration (header)")

          -- Ctrl-]: go to definition; if that file is already shown in another window, jump there
          map("<C-]>", function() vim.lsp.buf.definition({ reuse_win = true }) end, "Go to Definition")

          -- <leader>gd: always open the definition in the other window (split right if there is none)
          map("<leader>gd", function()
            local cur = vim.api.nvim_get_current_win()
            vim.lsp.buf.definition({
              on_list = function(t)
                local item = t.items[1]
                if not item then return end
                -- pick the previous window if it is a normal file window, else any other normal window
                local function normal(w)
                  return w ~= cur and vim.api.nvim_win_get_config(w).relative == ""
                    and vim.bo[vim.api.nvim_win_get_buf(w)].buftype == ""
                end
                local target = vim.fn.win_getid(vim.fn.winnr("#"))
                if not (target ~= 0 and normal(target)) then
                  target = nil
                  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    if normal(w) then target = w break end
                  end
                end
                if target then vim.api.nvim_set_current_win(target) else vim.cmd("vsplit") end
                vim.cmd("normal! m'") -- so Ctrl-o returns to where this window was
                vim.cmd.edit(vim.fn.fnameescape(item.filename))
                vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
                vim.cmd("normal! zz")
              end,
            })
          end, "Go to Definition (other window)")
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "clangd" then
            map("<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch Source/Header (C/C++)")
          end
        end,
      })

      -- Language servers to enable (installed via :Mason)
      vim.lsp.enable({ "clangd", "bashls", "rust_analyzer" })
    end,
  },
}
