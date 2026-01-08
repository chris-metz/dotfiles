-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "sql" },
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "go" then
      vim.keymap.set("n", "<leader>r", ":!go run %<CR>", { buffer = true, desc = "Run current Go file" })
      -- vim.keymap.set("n", "<leader>r", ":GoRun<cr>", { buffer = true, desc = "Run current Go file" })
    elseif filetype == "sql" then
      vim.keymap.set("n", "<leader>r", ":DB < % <cr>", { buffer = true, desc = "Run current SQL file" })
    end
  end,
})

-- local wk = require("which-key")
--
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "go",
--   callback = function()
--     -- Register filetype-specific keybindings with which-key
--     wk.register({
--       ["<leader>gor"] = { ":!go run %<CR>", "Run Go file" }, -- You can add more keybindings here
--     }, { buffer = 0, mode = "n", prefix = "<leader>" })
--   end,
-- })
