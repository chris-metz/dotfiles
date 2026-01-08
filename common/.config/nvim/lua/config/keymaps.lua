-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "ö", ":")
-- vim.keymap.set("n", "<C-q>", ":q<cr>")
vim.keymap.set("i", "jj", "<esc>")

-- execute sql script in current dadbot context
vim.keymap.set("n", "<F5>", ":DB < % <cr>")

vim.keymap.set("n", "<leader>gn", ":Neogit<CR>", { noremap = true, silent = true, desc = "Open Neogit" })

vim.keymap.set("n", "<leader>fC", ":let @+ = expand('%:p')<CR>", { desc = "Copy file path to clipboard" })
-- Map F5 to run :DBExecuteFile
-- vim.api.nvim_set_keymap("n", "<F5>", ":DBExecuteFile<CR>", { noremap = true, silent = true })

-- function Execute_sql_file()
--   -- Load environment variables from the .env file
--   vim.cmd("Dotenv")
--
--   -- Check if DATABASE_URL is set
--   if vim.env.DATABASE_URL == nil or vim.env.DATABASE_URL == "" then
--     vim.notify("DATABASE_URL not found in the .env file.", vim.log.levels.ERROR)
--     return
--   end
--
--   -- Read the content of the current SQL file
--   local filepath = vim.fn.expand("%:p")
--   local file = io.open(filepath, "r")
--   if not file then
--     vim.notify("Unable to open SQL file: " .. filepath, vim.log.levels.ERROR)
--     return
--   end
--
--   local sql_query = file:read("*all")
--   file:close()
--
--   if sql_query == "" then
--     vim.notify("SQL file is empty!", vim.log.levels.ERROR)
--     return
--   end
--
--   -- Create a new buffer for the results
--   local result_buf = vim.api.nvim_create_buf(false, true) -- Create a new unlisted scratch buffer
--   vim.api.nvim_buf_set_option(result_buf, "bufhidden", "wipe") -- Auto-delete the buffer when closed
--
--   -- Set the new buffer as the active buffer
--   vim.api.nvim_set_current_buf(result_buf)
--
--   -- Execute the query using psql and display the result in the new buffer
--   vim.fn.jobstart({ "psql", vim.env.DATABASE_URL, "-c", sql_query }, {
--     stdout_buffered = true,
--     on_stdout = function(_, data)
--       if data then
--         vim.api.nvim_buf_set_lines(result_buf, -1, -1, false, data)
--       end
--     end,
--     on_stderr = function(_, data)
--       if data then
--         vim.api.nvim_buf_set_lines(result_buf, -1, -1, false, data)
--       end
--     end,
--     on_exit = function(_, exit_code)
--       if exit_code == 0 then
--         vim.notify("Query executed successfully!", vim.log.levels.INFO)
--       else
--         vim.notify("Query execution failed.", vim.log.levels.ERROR)
--       end
--     end,
--   })
-- end
--
-- -- Create a command to execute the function
-- vim.cmd([[
-- command! DBExecuteFile lua Execute_sql_file()
-- ]])
